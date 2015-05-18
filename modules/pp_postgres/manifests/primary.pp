class pp_postgres::primary(
  $stagecraft_password,
  $env_sync_password,
) {
  include('pp_postgres::server')
  include('pp_postgres::backup')
  include('pp_postgres::monitoring::primary')

  pp_postgres::db { 'stagecraft':
    password => $stagecraft_password,
  }
  postgresql::server::config_entry { 'wal_level':
    value => 'hot_standby',
  }
  postgresql::server::config_entry { 'max_wal_senders':
    value => 3,
  }
  postgresql::server::config_entry { 'checkpoint_segments':
    value => 8,
  }
  postgresql::server::config_entry { 'wal_keep_segments':
    value => 8,
  }
  postgresql::server::config_entry { 'log_hostname':
    value => 'on',
  }
  pp_postgres::hba_rule { 'replicator':
    database    => 'replication',
    auth_method => 'trust',
  }
  postgresql::server::role { 'replicator':
    login            => true,
    replication      => true,
    connection_limit => 1,
  }

  file { '/etc/postgresql/find_bad_seqs.sql':
    source  => 'puppet:///modules/pp_postgres/etc/postgresql/find_bad_seqs.sql',
    owner   => 'postgres',
    require => Pp_postgres::Db['stagecraft'],
  }
  exec { 'add_find_bad_seqs_function':
    command => '/usr/bin/psql stagecraft -f /etc/postgresql/find_bad_seqs.sql',
    user    => 'postgres',
    require => File['/etc/postgresql/find_bad_seqs.sql'],
  }

  postgresql::server::role { 'env-sync':
    superuser     => true,
    password_hash => postgresql_password('env-sync', $env_sync_password),
  }

  postgresql::server::pg_hba_rule { 'local access as env-sync user':
    type        => 'local',
    database    => 'all',
    user        => 'env-sync',
    auth_method => 'md5',
    order       => '001', # necessary to ensure this is before the 'local all all ident' rule.
  }

}
