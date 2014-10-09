class performanceplatform::nodejs {
  package { 'nodejs':
    ensure  => "0.10.32-1chl1~${::lsbdistcodename}1",
    require => Apt::Ppa['ppa:gds/performance-platform'],
  }
  package { 'grunt-cli':
    ensure   => '0.1.9',
    provider => 'npm',
    require  => Package['nodejs'],
  }
}
