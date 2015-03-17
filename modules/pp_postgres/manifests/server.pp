class pp_postgres::server {
  include('postgresql::server')

  apt::pin { 'apt.postgresql.org':
    originator => 'apt.postgresql.org',
    priority   => 500,
  }->
  apt::source { 'apt.postgresql.org':
    location    => 'http://apt.postgresql.org/pub/repos/apt/',
    release     => "${::lsbdistcodename}-pgdg",
    repos       => "main ${::postgresql::globals::version}",
    key         => 'ACCC4CF8',
    key_source  => 'http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc',
    include_src => false,
  }

  Apt::Source['apt.postgresql.org']->Package<|tag == 'postgresql'|>

  # reccommended logging settings for https://github.com/dalibo/pgbadger
  postgresql::server::config_entry { 'logging_collector':
      value => 'on',
  }
  postgresql::server::config_entry { 'log_min_duration_statement':
      value => '0',
  }
  postgresql::server::config_entry { 'log_line_prefix':
      value => '%t [%p]: [%l-1] user=%u,db=%d,client=%h ',
  }
  postgresql::server::config_entry { 'log_checkpoints':
      value => 'on',
  }
  postgresql::server::config_entry { 'log_connections':
      value => 'on',
  }
  postgresql::server::config_entry { 'log_disconnections':
      value => 'on',
  }
  postgresql::server::config_entry { 'log_lock_waits':
      value => 'on',
  }
  postgresql::server::config_entry { 'log_temp_files':
      value => '0',
  }
  postgresql::server::config_entry { 'log_autovacuum_min_duration':
      value => '0',
  }
}
