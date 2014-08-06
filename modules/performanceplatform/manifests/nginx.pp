class performanceplatform::nginx {
  include performanceplatform::nginx::logging_formats
  include performanceplatform::nginx::status

  collectd::plugin::nginx { 'localhost':
    url => 'http://localhost:8433',
  }
}
