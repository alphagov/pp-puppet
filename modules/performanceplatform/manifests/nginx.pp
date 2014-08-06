class performanceplatform::nginx {
  include performanceplatform::nginx::logging_formats
  include performanceplatform::nginx::status

  class { 'collectd::plugin::nginx':
    url => 'http://localhost:8433',
  }
}
