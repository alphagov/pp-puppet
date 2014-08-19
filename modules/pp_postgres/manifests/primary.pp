class pp_postgres::primary(
  $stagecraft_password,
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
  pp_postgres::hba_rule { 'replicator':
    database    => 'replication',
    auth_method => 'trust',
  }
  postgresql::server::role { 'replicator':
    login            => true,
    replication      => true,
    connection_limit => 1,
  }

  postgresql_psql { 'collectd-postgres-replication-status-function':
    command => template('pp_postgres/collectd-query-replication-status.sql.erb'),
    unless => 'SELECT 1 FROM pg_catalog.pg_proc p WHERE p.proname = \'streaming_slave_check\' AND pg_catalog.pg_function_is_visible(p.oid)'
  }
  file { 'collectd-postgres-replication-query':
    ensure => present,
    path =>'/etc/collectd/conf.d/20-postgresql-query-replication-status.conf',
    owner => root,
    group => root,
    mode => '0640',
    source => 'puppet:///modules/pp_postgres/collectd-query-replication-status.conf',
    notify => Service['collectd'],
    require => Class['collectd::plugin::postgresql'],
  }

}
