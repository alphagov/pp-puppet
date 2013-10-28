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

}
