# === Parameters
#
# [*request_uuid*]
#   Optional boolean value. Whether to proxy_set_header the $request_uuid value or not.
#   If set, this can be used to trace a request through all the systems that collaborate
#   to service a single external request
#
define performanceplatform::app (
  $ensure                      = 'present',
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
  $add_header                  = undef,
) {

  validate_bool($request_uuid)

  if $ensure == 'present' {
      $ensure_directory = 'directory'
  }
  else {
      $ensure_directory = 'absent'
  }

  include nginx
  include upstart

  $log_path = "/var/log/${title}"

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
          "${app_path}/shared/log", "${app_path}/shared/log/audit",
          "${app_path}/shared/assets", $config_path, $log_path]:
    ensure => $ensure_directory,
    owner  => $user,
    group  => $group,
  }

  performanceplatform::proxy_vhost { "${title}-vhost":
    ensure                      => $ensure,
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
    add_header                  => $add_header,
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
    ensure        => $ensure,
    description   => $upstart_desc,
    respawn       => true,
    respawn_limit => '5 10',
    user          => $user,
    group         => $group,
    chdir         => "${app_path}/current",
    environment   => merge($base_environment, $extra_env),
    exec          => $upstart_exec,
  }

  logstashforwarder::file   { "app-logs-for-${title}":
    paths  => [ "/opt/${title}/current/log/*.log.json" ],
    fields => {
      'application' => $title,
      'log_type'    => 'application',
    },
  }

  logstashforwarder::file   { "auditing-logs-for-${title}":
    paths  => [ "/opt/${title}/current/log/audit/*.log.json" ],
    fields => {
      'application' => $title,
      'log_type'    => 'audit',
    },
  }

  logstashforwarder::file  { "var-logs-for-${title}":
    paths  => [ "/var/log/${title}/*.log.json"],
    fields => {
      'application' => $title,
      'log_type'    => 'application',
    },
  }

}
