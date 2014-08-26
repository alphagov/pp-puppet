class pp_postgres::monitoring::base {
  postgresql::server::config_entry { 'track_activities':
    value => 'on',
  }
  postgresql::server::config_entry { 'track_counts':
    value => 'on',
  }
  postgresql::server::config_entry { 'track_functions':
    value => 'none',
  }

  postgresql::server::role { 'monitoring':
    login            => true,
    connection_limit => 1,
    password_hash    => postgresql_password('monitoring', 'monitoring'),
  }
  postgresql::server::pg_hba_rule { 'monitoring':
    type        => 'host',
    database    => 'all',
    user        => 'monitoring',
    auth_method => 'md5',
    address     => '127.0.0.1/32',
  }
}
