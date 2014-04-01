class performanceplatform::checks::backups (
) {
    $freshness_script ="/etc/sensu/check-directory-freshness.sh"

    file { $freshness_script:
      require => Class['sensu'],
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/files/check-directory-freshness.sh"
    }

    sensu::check { 'postgresql_backups_copy_check':
      interval => 3600,
      command  => "${freshness_script} /mnt/data/backups/postgresql",
      handlers => ['default'],
    }

    sensu::check { 'mongo_backups_copy_check':
      interval => 3600,
      command  => "${freshness_script} /mnt/data/backups/mongodb",
      handlers => ['default'],
    }
}
