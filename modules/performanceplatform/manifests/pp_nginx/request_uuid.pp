class performanceplatform::pp_nginx::request_uuid {
  package { 'libossp-uuid-perl':
    ensure => installed,
  }

  file { '/etc/nginx/conf.d/02-request-uuid.conf':
    ensure  => present,
    source  => 'puppet:///modules/performanceplatform/nginx/request-uuid.conf',
    require => Class['nginx::config'],
    notify  => Service['nginx'],
  }
}
