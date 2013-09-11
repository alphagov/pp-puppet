
class performanceplatform::monitoring (
) {

  file { '/etc/apache2/run':
    ensure  => 'link',
    target  => '/var/run/apache2',
    subscribe  => Service['apache2'],
  }

  file { '/etc/nginx/htpasswd':
    ensure  => present,
    content => 'betademo:cBxAp7qb7cNXc', # nottobes
    subscribe  => Service['nginx'],
  }

}
