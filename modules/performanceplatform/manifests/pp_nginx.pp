class performanceplatform::pp_nginx {
  include performanceplatform::pp_nginx::logging_formats
  include performanceplatform::pp_nginx::status

  class { 'collectd::plugin::nginx':
    url => 'http://localhost:8433',
  }
}
