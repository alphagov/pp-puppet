class performanceplatform::checks::stagecraft (
) {
    $check_data_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

    sensu::check { "stagecraft_basic_status_health_check":
      interval => 120,
      command  => "${check_data_path}  -u http://localhost:3204/_status",
      handlers => ['default'],
    }

    sensu::check { "stagecraft_access_data_sets_health_check":
      interval => 120,
      command  => "${check_data_path}  -u http://localhost:3204/_status/data-sets",
      handlers => ['default'],
    }
}
