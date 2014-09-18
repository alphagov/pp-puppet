# === Parameters
#
# [*request_uuid*]
#   Optional boolean value. Whether to proxy_set_header the $request_uuid value or not.
#   If set, this can be used to trace a request through all the systems that collaborate
#   to service a single external request
#
define performanceplatform::app (
  $port                        = undef,
  $workers                     = 4,
  $app_module                  = undef,
  $user                        = undef,
  $group                       = undef,
  $app_path                    = "/opt/${title}",
  $config_path                 = "/etc/gds/${title}",
  $servername                  = $title,
  $serveraliases               = undef,
  $proxy_ssl                   = false,
  $extra_env                   = {},
  $upstart_desc                = "Upstart job for ${title}",
  $upstart_exec                = "${app_path}/run-procfile.sh",
  $proxy_append_forwarded_host = false,
  $proxy_set_forwarded_host    = false,
  $client_max_body_size        = '10m',
  $statsd_prefix               = $title,
  $ssl_cert                    = hiera('public_ssl_cert'),
  $ssl_key                     = hiera('public_ssl_key'),
  $request_uuid                = false,
) {

  validate_bool($request_uuid)

  include nginx
  include upstart

  $log_path = "/var/log/${title}"

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
          "${app_path}/shared/log", "${app_path}/shared/assets", $config_path, $log_path]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  performanceplatform::proxy_vhost { "${title}-vhost":
    port                        => 80,
    upstream_port               => $port,
    servername                  => $servername,
    serveraliases               => $serveraliases,
    ssl                         => $proxy_ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    proxy_append_forwarded_host => $proxy_append_forwarded_host,
    proxy_set_forwarded_host    => $proxy_set_forwarded_host,
    client_max_body_size        => $client_max_body_size,
    request_uuid                => $request_uuid,
  }

  $base_environment = {
    # rails style development/production environment
    'GOVUK_ENV'           => 'production',
    # the actual env we are running in: preview, staging, production
    'INFRASTRUCTURE_ENV'  => $::pp_environment,
    'APP_NAME'            => $title,
    'APP_MODULE'          => $app_module,
    'GOVUK_STATSD_PREFIX' => "pp.apps.${statsd_prefix}",
  }

  upstart::job { $title:
    description   => $upstart_desc,
    respawn       => true,
    respawn_limit => '5 10',
    user          => $user,
    group         => $group,
    chdir         => "${app_path}/current",
    environment   => merge($base_environment, $extra_env),
    exec          => $upstart_exec,
  }

  lumberjack::logshipper { "app-logs-for-${title}":
    log_files => [ "/opt/${title}/current/log/*.log.json" ],
    fields    => { 'application' => $title },
  }
  sensu::check { "lumberjack_is_down_for_app-logs-for-${title}":
    command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'lumberjack.*app-logs-for-${title}' -C 1 -W 1",
    interval => 60,
    handlers => ['default'],
  }

  lumberjack::logshipper { "var-logs-for-${title}":
    log_files => [ "/var/log/${title}/*.log.json"],
    fields    => { 'application' => $title },
  }
  sensu::check { "lumberjack_is_down_for_var-logs-for-${title}":
    command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'lumberjack.*var-logs-for-${title}' -C 1 -W 1",
    interval => 60,
    handlers => ['default'],
  }
}
