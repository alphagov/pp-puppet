class performanceplatform::monitoring::graphite (
) {

  Class['::graphite'] -> Class['::nginx']

  file { '/etc/apache2/run':
    ensure  => link,
    target  => '/var/run/apache2',
    require => Package[$::graphite::params::apache_pkg],
    notify  => Service['apache2'],
  }

  logrotate::rule { 'graphite-rotate':
    path          => '/opt/graphite/storage/*.log',
    rotate        => 30,
    rotate_every  => 'day',
    missingok     => true,
    compress      => true,
    create        => true,
    sharedscripts => true,
    create_mode   => '0640',
    postrotate    => '/etc/init.d/apache2 reload > /dev/null',
  }

  file { '/opt/graphite/conf/storage-aggregation.conf':
    mode    => '0644',
    source  => 'puppet:///modules/performanceplatform/graphite/storage-aggregation.conf',
    require => Anchor['graphite::install::end'],
    notify  => Service['carbon-cache'],
  }

  file { '/etc/nginx/htpasswd':
    ensure    => present,
    content   => "${::basic_auth_username}:${::basic_auth_password_hashed}",
    subscribe => Service['nginx'],
  }

}
