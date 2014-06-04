class performanceplatform::jenkins(
  $lts,
  $plugin_hash,
) {

  class { '::jenkins':
    lts         => $lts,
    plugin_hash => $plugin_hash,
  }
  contain 'jenkins'

  package { 'keychain':
    ensure  => installed,
    require => Class['::jenkins']
  }

}
