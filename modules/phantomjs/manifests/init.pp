class phantomjs {

  include curl

  curl::fetch { 'download phantomjs':
    source      => 'https://gds-public-readable-tarballs.s3.amazonaws.com/phantomjs-1.9.1-linux-x86_64.tar.bz2',
    destination => '/usr/local/src/phantomjs-1.9.1-linux-x86_64.tar.bz2',
    timeout     => 3600,
  }

  exec { 'unpack phantomjs':
    require => Curl::Fetch['download phantomjs'],
    creates => '/usr/local/src/phantomjs-1.9.1-linux-x86_64',
    cwd     => '/usr/local/src',
    command => '/bin/tar -jxf ./phantomjs-1.9.1-linux-x86_64.tar.bz2'
  }

  file { '/usr/local/bin/phantomjs':
    ensure  => link,
    target  => '/usr/local/src/phantomjs-1.9.1-linux-x86_64/bin/phantomjs',
    require => Exec['unpack phantomjs'],
  }

  package { 'libfontconfig1':
    ensure => present,
  }

}
