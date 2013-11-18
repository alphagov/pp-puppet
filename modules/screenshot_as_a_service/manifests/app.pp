class screenshot_as_a_service::app (
  $port       = undef,
  $workers    = 4,
  $app_module = undef,
  $user       = undef,
  $group      = undef,
) {
  include performanceplatform::nodejs

  performanceplatform::app { 'screenshot_as_a_service':
    port         => $port,
    workers      => $workers,
    app_module   => $app_module,
    user         => $user,
    group        => $group,
    servername   => $::screenshot_as_a_service_vhost,
    proxy_ssl    => true,
    extra_env    => {
      'NODE_ENV' => $::pp_environment,
    },
    upstart_desc => 'Screenshot as a service job',
    upstart_exec => 'node app.js',
  }
}
