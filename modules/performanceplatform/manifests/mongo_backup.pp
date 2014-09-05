# Class: mongo::backup
#
# Parameters:
#   ['backup_dir'] - The directory to use for backups.
#
#   ['user']       - User writing out the backups.
#
#   ['backup_log'] - The log file to write success/failure of backing up.
#
# Requires:
# - `puppetlabs/stdlib`
#
# Sample Usage:
#   include mongodb::backup
#
class performanceplatform::mongo_backup (
  $database       = 'backdrop',
  $backup_dir     = '/var/backups/mongodb',
  $backup_log_dir = '/var/log/backups/',
  $backup_log     = '/var/log/backups/mongodb.log',
  $user           = 'root',
) {

  file {$backup_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  file {$backup_log_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  file {$backup_log:
    ensure => present,
    owner  => $user,
    group  => $user,
    mode   => '0777',
  }

  file { '/usr/local/bin/mongo-backup.sh':
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    content => template('performanceplatform/mongo-backup.sh.erb'),
    require => File[$backup_dir],
  }

  cron { 'mongo-backup':
    command => '/usr/local/bin/mongo-backup.sh',
    user    => $user,
    hour    => 3,
    minute  => 0,
    require => File['/usr/local/bin/mongo-backup.sh'],
  }

  sensu::check { 'mongodb_backed_up_less_than_24hrs_ago':
    command  => '/etc/sensu/community-plugins/plugins/files/check-tail.rb -f /var/log/backups/mongodb.log -l 1 -P failed',
    interval => 86400,
    handlers => ['default'],
  }


}
