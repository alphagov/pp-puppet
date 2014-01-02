class spotlight::app (
  $port       = undef,
  $workers    = 4,
  $app_module = undef,
  $user       = undef,
  $group      = undef,
) {
  include performanceplatform::nodejs
  include performanceplatform::spotlight_checks

  # spotlight_vhost and spotlight_vhost_internal are the same
  # in every environment except production. Once GOV.UK is
  # routing to the internal vhost rather than the "public" one,
  # we should remove the public vhost from this config.
  performanceplatform::app { 'spotlight':
    port          => $port,
    workers       => $workers,
    app_module    => $app_module,
    user          => $user,
    group         => $group,
    servername    => $::spotlight_vhost,
    serveraliases => $::spotlight_vhost_internal,
    proxy_ssl     => true,
    magic         => template('spotlight/assets-redirect.erb'),
    extra_env     => {
      'NODE_ENV' => $::pp_environment,
    },
    upstart_desc  => 'Spotlight job',
    upstart_exec  => 'node app/server.js',
    proxy_append_forwarded_host => false,
  }
}
