define spotlight::app (
  $port        = undef,
  $workers     = 4,
  $app_module  = undef,
  $user        = undef,
  $group       = undef,
) {
  $app_path    = "/opt/${title}"
  $config_path = "/etc/gds/${title}"

  include performanceplatform::nodejs

  performanceplatform::app { $title:
    port         => $port,
    workers      => $workers,
    app_module   => $app_module,
    user         => $user,
    group        => $group,
    extra_env    => {
      'NODE_ENV' => 'production',
    },
    app_path     => $app_path,
    config_path  => $config_path,
    upstart_desc => 'Spotlight job',
    upstart_exec => "node app/server.js",
  }
}
