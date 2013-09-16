
class performanceplatform::monitoring (
) {

  file { '/etc/apache2/run':
    ensure  => link,
    target  => '/var/run/apache2',
    require => Package["${::graphite::params::apache_pkg}"],
    notify  => Service['apache2'],
  }

  file { '/etc/nginx/htpasswd':
    ensure  => present,
    content => 'betademo:cBxAp7qb7cNXc', # nottobes
    subscribe  => Service['nginx'],
  }

  curl::fetch { 'logstash-jar':
    source      => 'https://logstash.objects.dreamhost.com/release/logstash-1.1.9-monolithic.jar',
    destination => '/var/tmp/logstash-1.1.9.jar',
    before      => Class['logstash'],
  }

}
