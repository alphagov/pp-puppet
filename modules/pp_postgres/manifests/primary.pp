class pp_postgres::primary(
  $stagecraft_password,
) {
  include("pp_postgres::server")

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

  postgresql::server::pg_hba_rule { 'replication':
    type        => 'host',
    database    => 'replication',
    user        => 'replicator',
    auth_method => 'trust',
    address     => '172.27.1.1/24'
  }
  postgresql::server::role { 'replicator':
    login            => true,
    replication      => true,
    connection_limit => 1,
  }
}
