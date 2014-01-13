class performanceplatform::dev (
) {
    package {['bowler']:
      ensure   => installed,
      provider => gem,
      require  => Package['ruby1.9.1-dev'],
    }
}
