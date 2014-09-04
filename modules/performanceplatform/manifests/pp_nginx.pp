class performanceplatform::pp_nginx {
  include performanceplatform::pp_nginx::logging_formats
  include performanceplatform::pp_nginx::status

  class { 'collectd::plugin::nginx':
    url => 'http://localhost:8433',
  }

  file { '/etc/apt/sources.list.d/nginx.list':
    ensure => 'absent',
    notify  => Exec['apt_update'],
  }

  file { '/etc/apt/sources.list.d/teward-nginx-devel-testing-precise.list':
    ensure => 'absent',
    notify  => Exec['apt_update'],
  }

}
