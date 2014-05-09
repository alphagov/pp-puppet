class performanceplatform::nginx_logging_formats(
) {

  file { '/etc/nginx/conf.d/00-logging.conf':
    ensure  => present,
    source  => 'puppet:///modules/performanceplatform/nginx/logging.conf',
    require => Class['nginx::config'],
    notify  => Service['nginx'],
  }

}
