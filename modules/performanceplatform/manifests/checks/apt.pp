class performanceplatform::checks::apt (
) {

  sensu::check { 'apt_reboot_check':
    command  => "check_reboot_required 3 1",
    interval => 6 * 60 * 60,  # every 6 hours
    handlers => ['default'],
    require  => Package['gds-nagios-plugins'],
  }

  sensu::check { 'apt_security_updates':
    command  => "check_apt_security_updates 0 0",
    interval => 6 * 60 * 60,  # every 6 hours
    handlers => ['default'],
    require  => Package['gds-nagios-plugins'],
  }

}
