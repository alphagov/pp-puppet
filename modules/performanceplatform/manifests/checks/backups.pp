class performanceplatform::checks::backups (
) {
    $freshness_script ='/etc/sensu/check-directory-freshness.sh'

    file { $freshness_script:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0777',
      source => 'puppet:///modules/performanceplatform/check-directory-freshness.sh'
    }

    sensu::check { 'postgresql_backups_copy_check':
      interval => 3600,
      command  => "${freshness_script} /mnt/data/backup/postgresql",
      handlers => ['default'],
      require  => File[$freshness_script],
    }

    sensu::check { 'mongo_backups_copy_check':
      interval => 3600,
      command  => "${freshness_script} /mnt/data/backup/mongodb",
      handlers => ['default'],
      require  => File[$freshness_script],
    }
}
