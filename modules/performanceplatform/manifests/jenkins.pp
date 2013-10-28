class performanceplatform::jenkins(
  $lts,
  $plugin_hash,
) {

  class { '::jenkins':
    lts         => $lts,
    plugin_hash => $plugin_hash,
  }

  package { 'keychain':
    ensure  => installed,
    require => Class['::jenkins']
  }

  file { '/var/lib/jenkins/.bashrc':
    source  => 'puppet:///modules/performanceplatform/jenkins-bashrc',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0700',
    require => Package['keychain']
  }

}
