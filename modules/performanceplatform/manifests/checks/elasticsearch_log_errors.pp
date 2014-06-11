class performanceplatform::checks::elasticsearch_log_errors(
) {
    $log_errors_checker_script ="/etc/sensu/check_elasticsearch_log_errors.py"

    file { $log_errors_checker_script:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check_elasticsearch_log_errors.py"
    }

    sensu::check { 'python_log_errors_in_last_hour':
      interval => 60,
      command  => $log_errors_checker_script,
      handlers => ['default'],
      require  => File[$log_errors_checker_script],
    }
}
