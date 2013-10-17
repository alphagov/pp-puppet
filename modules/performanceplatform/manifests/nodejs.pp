class performanceplatform::nodejs {
  package { 'nodejs':
    ensure  => "0.10.20-1chl1~${::lsbdistcodename}1",
    require => Apt::Ppa['ppa:gds/performance-platform']
  }
  package { 'nodeenv':
    ensure   => '0.7.0',
    provider => 'pip',
    require  => Package['nodejs'],
  }
}
