class java7 ($download_url) {
  # Agree to the Oracle license agreement, so that we can install Java 7, so
  # that we can install ElasticSearch

  $download_dir= '/var/cache/oracle-jdk7-installer'
  file {$download_dir:
    ensure => directory,
  }

  exec { 'download-oracle-java7':
    command => "/usr/bin/curl -o jdk-7u9-linux-x64.tar.gz ${download_url}",
    cwd     => '/var/cache/oracle-jdk7-installer',
    require => [Package['curl'], File[$download_dir]],
    timeout => 3600,
    unless  => '/usr/bin/test "`shasum -a 256 jdk-7u9-linux-x64.tar.gz`" = "1b39fe2a3a45b29ce89e10e59be9fbb671fb86c13402e29593ed83e0b419c8d7  jdk-7u9-linux-x64.tar.gz"',
  }
  notify{"command => /usr/bin/curl -o jdk-7u9-linux-x64.tar.gz ${download_url}":}
  exec {
    'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';
    'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  }
  package { 'oracle-java7-installer':
    ensure  => present,
    require => [Exec['set-licence-selected'], Exec['set-licence-seen'], Exec['download-oracle-java7']],
  }
}
