class performanceplatform::dns {

  include dnsmasq

  $aliases = hiera('performanceplatform::dns::aliases', {})
  validate_hash($aliases)
  $cnames = hiera('performanceplatform::dns::cnames', {})
  validate_hash($cnames)
  $hosts = hiera('performanceplatform::dns::hosts', '')

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
