class pp_postgres::monitoring::primary {
  include('pp_postgres::monitoring::base')

  class {'collectd::plugin::postgresql':
    databases => {
      'stagecraft' => {
        'user' => 'monitoring',
        'password' => '',
        'query' => ['query_plans', 'queries', 'table_states', 'disk_io' ],
      }
    }
  }

  # Primary should have 5 processes for normal running; main, writer, wal writer, autovacuum launcher, stats collector
  #   and an additional process for replication; wal sender
  sensu::check { 'postgres_is_down':
    command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p postgres -C 5 -W 5',
    interval => 60,
    handlers => ['default'],
  }
}
