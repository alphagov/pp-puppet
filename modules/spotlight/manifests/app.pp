class spotlight::app (
  $port       = undef,
  $workers    = 4,
  $app_module = undef,
  $user       = undef,
  $group      = undef,
) {
  include performanceplatform::nodejs
  include performanceplatform::spotlight_checks

  performanceplatform::app { 'spotlight':
    port         => $port,
    workers      => $workers,
    app_module   => $app_module,
    user         => $user,
    group        => $group,
    servername   => $::spotlight_vhost,
    proxy_ssl    => true,
    magic        => template('spotlight/assets-redirect.erb'),
    extra_env    => {
      'NODE_ENV' => $::pp_environment,
    },
    upstart_desc => 'Spotlight job',
    upstart_exec => 'node app/server.js',
  }
}
