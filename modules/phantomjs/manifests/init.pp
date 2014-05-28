class phantomjs {

  package { 'phantomjs':
    ensure => '1.9.7-0~ppa1',
  }

  # FIXME: Remove when this has been run in all environments
  file { '/usr/local/bin/phantomjs':
    ensure  => absent,
  }

}
