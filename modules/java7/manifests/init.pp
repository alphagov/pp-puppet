class java7 {
  # Agree to the Oracle license agreement, so that we can install Java 7, so
  # that we can install ElasticSearch
  exec {
    'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';
    'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  }
  package { 'oracle-java7-installer':
    ensure  => present,
    require => [Exec['set-licence-selected'], Exec['set-licence-seen']],
  }
}
