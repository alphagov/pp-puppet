class performanceplatform::nxinx_status {
  file { '/etc/nginx/conf.d/01-stub-status.conf',
    ensure  => present,
    source  => 'puppet:///modules/performanceplatform/nginx/stub-status.conf',
    require => Class['nginx::config'],
    notify  => Service['nginx',
  }
}
