class performanceplatform::dns (
  $aliases = [],
  $cnames  = [],
  $hosts   = '',
) {

  include dnsmasq

  validate_array($aliases)
  validate_array($cnames)

  dnsmasq::conf { 'internal-dns':
      ensure  => present,
      content => template('performanceplatform/internal-dns.erb'),
  }

  file { '/etc/hosts.dns':
      content => $hosts,
      notify  => Class['dnsmasq::service'],
  }

  $nameservers = hiera('nameservers', ['8.8.8.8', '8.8.4.4'])
  validate_array($nameservers)

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
