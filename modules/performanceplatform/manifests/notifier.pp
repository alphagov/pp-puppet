class performanceplatform::notifier(
  $ensure = 'present',
  $user,
  $group,
  $cron_definition,
  $command = 'npm start',
  $app_path = '/opt/notifier',
  $log_path = '/var/log/notifier',
  $config_path = '/etc/gds/notifier',
) {

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

  lumberjack::logshipper { 'notifier-logshipper-app':
    ensure    => $ensure,
    log_files => [ "${app_path}/shared/log/app.log.json" ],
  }

  lumberjack::logshipper { 'notifier-logshipper-exceptions':
    ensure    => $ensure,
    log_files => [ "${app_path}/shared/log/exceptions.log.json" ],
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

  $cron_defs = {
    'notifier-cron-job' => $cron_definition,
  }

  create_resources(cron, $cron_defs, {
    ensure      => $ensure,
    command     => $command,
    user        => $user,
    environment => 'PATH=/bin:/usr/bin:/usr/sbin',
  })

}
