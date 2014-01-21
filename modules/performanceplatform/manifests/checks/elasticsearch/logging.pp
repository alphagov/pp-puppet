class performanceplatform::checks::elasticsearch::logging(
) {

  performanceplatform::checks::elasticsearch::index { 'logstash-current':
    type => 'lumberjack',
  }

  performanceplatform::checks::elasticsearch::index { 'logstash-current':
    type => 'syslog',
  }

}
