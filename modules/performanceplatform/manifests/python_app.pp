define performanceplatform::python_app (
  $description     = $title,
  $app_path        = "/opt/${title}",
  $config_path     = "/etc/gds/${title}",
  $virtualenv_path = "${app_path}/shared/venv",
  $app_module      = undef,
  $user            = undef,
  $group           = undef,
  $extra_env       = {},
  $statsd_prefix   = $title,
  $log_path        = "/var/log/${title}",
  $upstart_desc    = $title,
  $upstart_exec    = undef,
) {

  include upstart

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
      "${app_path}/shared/log", "${app_path}/shared/assets", $config_path, $log_path]:
    ensure => directory,
    owner  => $user,
    group  => $group,
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
