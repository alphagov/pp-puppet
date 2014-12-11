class performanceplatform::notifier(
  $ensure = 'present',
  $user,
  $group,
  $cron_definition,
  $app_path = undef,
  $log_path = '/var/log/performanceplatform-notifier',
  $config_path = '/etc/gds/performanceplatform-notifier',
) {

  validate_string($app_path)

  include performanceplatform::nodejs

  if $ensure == 'present' {
    $ensure_directory = 'directory'
  }
  else {
    $ensure_directory = 'absent'
  }

  file { [$log_path, $config_path, $app_path, "${app_path}/releases", "${app_path}/shared", "${app_path}/shared/log"]:
    ensure  => $ensure_directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    force   => true,
  }

  logstashforwarder::file { 'notifier-logshipper-app':
    paths  => [ "${app_path}/shared/log/app.log.json" ],
  }

  logstashforwarder::file { 'notifier-logshipper-exceptions':
    paths  => [ "${app_path}/shared/log/exceptions.log.json" ],
  }

  logrotate::rule { 'notifier-logrotate-json':
    path         => "${app_path}/shared/log/*.log.json",
    rotate       => 10,
    rotate_every => 'day',
    missingok    => true,
    compress     => true,
    create       => true,
    create_mode  => '0640',
    create_owner => $user,
    create_group => $group,
  }

  # Create notifier cronjobs
  create_resources(cron, $cron_definition, {
    ensure      => $ensure,
    user        => $user,
    environment => 'PATH=/bin:/usr/bin:/usr/sbin',
  })

}
