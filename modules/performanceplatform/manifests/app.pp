define performanceplatform::app (
  $port         = undef,
  $workers      = 4,
  $app_module   = undef,
  $user         = undef,
  $group        = undef,
  $app_path     = "/opt/${title}",
  $config_path  = "/etc/gds/${title}",
  $servername   = $title,
  $serveraliases = undef,
  $proxy_ssl    = false,
  $extra_env    = {},
  $upstart_desc = "Upstart job for ${title}",
  $upstart_exec = "${app_path}/run-procfile.sh",
  $proxy_append_forwarded_host = false,
  $proxy_set_forwarded_host = false,
  $client_max_body_size = '10m',
) {
  include nginx
  include upstart

  $log_path = "/var/log/${title}"

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
          "${app_path}/shared/log", $config_path, $log_path]:
    ensure  => directory,
    owner   => $user,
    group   => $group,
  }

  performanceplatform::proxy_vhost { "${title}-vhost":
    port                        => 80,
    upstream_port               => $port,
    servername                  => $servername,
    serveraliases               => $serveraliases,
    ssl                         => $proxy_ssl,
    proxy_append_forwarded_host => $proxy_append_forwarded_host,
    proxy_set_forwarded_host    => $proxy_set_forwarded_host,
    client_max_body_size        => $client_max_body_size,
  }

  $base_environment = {
    "GOVUK_ENV"  => "production",
    "APP_NAME"   => $title,
    "APP_MODULE" => $app_module,
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
  }

  lumberjack::logshipper { "var-logs-for-${title}":
    log_files => [ "/var/log/${title}/*.log.json"],
  }
}
