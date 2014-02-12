# Class: postgresql::backup
#
# This class provides a way to set up backup for a postgresql cluster.
# It will add a shell script based on the utility pg_dump to make
# consitent backups each night.
#
# You must have declared the `postgresql` class before you use
# this class.
#
# Parameters:
#   ['backup_dir']    - The directory to use for backups.
#                       Defaults to /var/backups/pgsql.
#   ['backup_format'] - The backup format to use.
#                       Defaults to plain.
#   ['user']          - The user to use to perform the backup.
#                       Defaults to postgres.
#
# Actions:
# - Creates and manages a postgresql cluster
#
# Requires:
# - `puppetlabs/stdlib`
#
# Sample Usage:
#   include postgresql::backup
#
class performanceplatform::postgresql_backup (
  $backup_dir = '/var/backups/pgsql',
  $backup_format = 'plain',
  $user = 'postgres',
) {

  file {$backup_dir:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    #require => [Package['puppetlabs/postgresql'], User[$user]],
  }

  file { '/usr/local/bin/pgsql-backup.sh':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('performanceplatform/pgsql-backup.sh.erb'),
    require => File[$backup_dir],
  }

  cron { 'pgsql-backup':
    command => "/usr/local/bin/pgsql-backup.sh",
    user    => $user,
    hour    => 2,
    minute  => 0,
    # require => [User[$user], File['/usr/local/bin/pgsql-backup.sh']],
    require => File['/usr/local/bin/pgsql-backup.sh'],
  }

}
