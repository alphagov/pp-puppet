class spotlight::app (
  $port       = undef,
  $workers    = 4,
  $app_module = undef,
  $user       = undef,
  $group      = undef,
) {
  include performanceplatform::nodejs

  performanceplatform::app { 'spotlight':
    port         => $port,
    workers      => $workers,
    app_module   => $app_module,
    user         => $user,
    group        => $group,
    servername   => "${::spotlight_vhost}",
    extra_env    => {
      'NODE_ENV' => 'production',
    },
    upstart_desc => 'Spotlight job',
    upstart_exec => 'node app/server.js',
  }
}
