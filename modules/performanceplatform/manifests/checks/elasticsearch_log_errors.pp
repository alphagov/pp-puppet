class performanceplatform::checks::elasticsearch_log_errors(
) {
    $log_errors_checker_script = "/etc/sensu/check_elasticsearch_log_errors.py"
    $all_errors_json_query = "/etc/sensu/check_error_logs_all.json"
    $ga_errors_json_query = "/etc/sensu/check_error_logs_ga.json"

    file { $log_errors_checker_script:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check_elasticsearch_log_errors.py"
    }

    file { $ga_errors_json_query:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check_error_logs_ga.json"
    }

    file { $all_errors_json_query:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check_error_logs_all.json"
    }

    sensu::check { 'collector_errors_in_last_hour':
      interval => 60,
      command  => "${log_errors_checker_script} ${all_errors_json_query}",
      handlers => ['default'],
      require  => [File[$log_errors_checker_script],File[$all_errors_json_query]],
    }

    sensu::check { 'ga_collector_errors_in_last_24hrs':
      interval => 3600,
      command  => "${log_errors_checker_script} ${ga_errors_json_query}",
      handlers => ['default'],
      require  => [File[$log_errors_checker_script],File[$ga_errors_json_query]],
    }
}
