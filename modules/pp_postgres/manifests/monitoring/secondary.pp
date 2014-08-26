class pp_postgres::monitoring::secondary {
  include('pp_postgres::monitoring::base')

  collectd::plugin::postgresql::database{'stagecraft':
    user     => 'monitoring',
    password => 'monitoring',
    host     => 'localhost',
    query    => ['query_plans', 'queries', 'table_states', 'disk_io'],
  }

  # Secondary should have 5 processes; main, startup, writer, stats collector, wal receiver
  sensu::check { 'postgres_is_down':
    command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p postgres -C 5 -W 5',
    interval => 60,
    handlers => ['default'],
  }
}
