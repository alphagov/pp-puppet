class performanceplatform::dns (
  $aliases    = [],
  $cnames     = [],
  $hosts      = '',
  $env_hosts  = '',
) {

  include dnsmasq

  validate_array($aliases)
  validate_array($cnames)

  $unique_cnames = unique($cnames)

  dnsmasq::conf { 'internal-dns':
      ensure  => present,
      content => template('performanceplatform/internal-dns.erb'),
  }

  file { '/etc/hosts.dns':
      content => "${hosts}\n${env_hosts}",
      notify  => Class['dnsmasq::service'],
  }

  $nameservers = hiera_array('nameservers', ['8.8.8.8', '8.8.4.4'])
  validate_array($nameservers)

  dnsmasq::conf { 'explicit-nameservers':
      ensure  => present,
      content => template('performanceplatform/explicit-nameservers.erb'),
  }

  $domainname = 'internal'
  $searchpath = 'internal'
  $options    = ['timeout:1']
  $use_local_resolver = true

  file { '/etc/resolvconf/resolv.conf.d/head':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('performanceplatform/resolv.conf.erb'),
    notify  => Class['dnsmasq::service'],
  }

}
