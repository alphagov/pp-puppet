class performanceplatform::checks::backdrop (
) {
    $check_data_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

    sensu::check { 'backdrop_read_health_check':
      interval => 120,
      command  => "${check_data_path}  -u http://localhost:3038/_status",
      handlers => ['default'],
    }
    sensu::check { 'backdrop_write_health_check':
      interval => 120,
      command  => "${check_data_path} -u http://localhost:3039/_status",
      handlers => ['default'],
    }
    sensu::check { 'backdrop_admin_health_check':
      ensure   => 'absent',
      interval => 120,
      command  => "${check_data_path} -u http://localhost:3203/_status",
      handlers => ['default'],
    }
    sensu::check { 'backdrop_data_sets_health_check':
      ensure  => absent,
      command => "${check_data_path}  -u http://localhost:3038/_status/data-sets",
    }
}
