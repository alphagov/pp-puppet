class performanceplatform::init_remove_lumberjack(
  $hosts,
  $deb_source,
  $cert_source,
  $config_dir = '/etc/lumberjack',
  $deb_path = '/var/tmp/lumberjack.deb',
  $cert_path = '/etc/ssl/lumberjack.pub',
) {

  file { $deb_path:
    ensure => absent
  }

  file { $cert_path:
    ensure => absent
  }

  package { 'lumberjack':
    ensure    => absent
  }

  file { $config_dir :
    ensure => absent
  }

}
