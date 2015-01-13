define performanceplatform::python_app (
  $ensure          = 'present',
  $description     = $title,
  $app_path        = "/opt/${title}",
  $config_path     = "/etc/gds/${title}",
  $virtualenv_path = undef,
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

  if $ensure == 'present' {
      $ensure_directory = 'directory'
  }
  else {
      $ensure_directory = 'absent'
  }

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
      "${app_path}/shared/log", "${app_path}/shared/assets", $config_path, $log_path]:
    ensure => $ensure_directory,
    owner  => $user,
    group  => $group,
  }

  python::virtualenv { $virtualenv_path:
    ensure     => $ensure,
    version    => '2.7',
    systempkgs => false,
    owner      => $user,
    group      => $group,
    require    => File["${app_path}/shared"],
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
    fields => { 'application' => $title },
  }

  logstashforwarder::file  { "var-logs-for-${title}":
    paths  => [ "/var/log/${title}/*.log.json"],
    fields => { 'application' => $title },
  }

}
