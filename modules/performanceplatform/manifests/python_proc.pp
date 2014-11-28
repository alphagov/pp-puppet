define performanceplatform::python_proc (
  $description   = $title,
  $app_module    = undef,
  $user          = undef,
  $group         = undef,
  $extra_env     = {},
  $statsd_prefix = $title,
  $upstart_exec  = undef,
  $upstart_desc  = undef,
) {
  include upstart

  $app_path        = "/opt/${title}"
  $config_path     = "/etc/gds/${title}"
  $virtualenv_path = "${app_path}/shared/venv"
  $log_path        = "/var/log/${title}"

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
      "${app_path}/shared/log", "${app_path}/shared/assets", $config_path, $log_path]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  python::virtualenv { $virtualenv_path:
    ensure     => present,
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
    description   => $upstart_desc,
    respawn       => true,
    respawn_limit => '5 10',
    user          => $user,
    group         => $group,
    chdir         => "${app_path}/current",
    environment   => merge($base_environment, $extra_env),
    exec          => $upstart_exec,
  }
}
