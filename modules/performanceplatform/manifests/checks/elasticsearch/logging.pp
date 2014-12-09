class performanceplatform::checks::elasticsearch::logging(
) {

  
  if $::pp_environment == 'production' {
    performanceplatform::checks::elasticsearch::index { 'check_lumberjack_logging_rate':
      index => 'logstash-current',
      type  => 'lumberjack',
    }

    performanceplatform::checks::elasticsearch::index { 'check_syslog_logging_rate':
      index => 'logstash-current',
      type  => 'syslog',
    }
  }

}
