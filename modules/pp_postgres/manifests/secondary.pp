class pp_postgres::secondary {
  include('pp_postgres::server')
  include('pp_postgres::monitoring::secondary')

  $data_dir = $::postgresql::params::data_dir
  $primary_host = 'postgresql-primary'

  file { "${data_dir}/recovery.conf":
    ensure  => present,
    content => "standby_mode = 'on'\nprimary_conninfo = 'host=postgresql-primary-1 user=replicator'",
    owner   => "postgres",
    group   => "postgres",
  }
  file { '/usr/local/bin/start_replication.sh':
    ensure  => present,
    content => template("pp_postgres/start_replication.sh.erb"),
    mode    => '0555',
  }

  postgresql::server::config_entry { 'hot_standby':
    value => 'on',
  }
  pp_postgres::hba_rule {'stagecraft':
  }
}
