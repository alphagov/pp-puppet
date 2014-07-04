class performanceplatform::checks::clamav (
) {

  sensu::check { 'clamav_is_down':
    command  => 'pgrep clamd',
    interval => 60,
    handlers => ['default']
  }

}
