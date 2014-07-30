class performanceplatform::checks::clamav (
) {
    $check_clamav_running_script = "/etc/sensu/check_clamav_daemon_running.sh"

    file { $check_clamav_running_script:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check_clamav_daemon_running.sh"
    }

    sensu::check { 'clamav_is_down':
      command  => $check_clamav_running_script,
      interval => 60,
      handlers => ['default']
    }

}
