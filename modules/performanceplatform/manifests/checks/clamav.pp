class performanceplatform::checks::clamav (
) {

  sensu::check { 'clamav_is_down':
    command  => '/etc/init.d/clamav-daemon status',
    interval => 60,
    handlers => ['default']
  }

}
