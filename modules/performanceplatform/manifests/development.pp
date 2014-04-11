class performanceplatform::development (
  $stagecraft_password
) {
  file { '/home/vagrant/.bash_profile':
    ensure  => file,
    replace => false,
    owner   => 'vagrant',
    group   => 'vagrant',
    source  => 'puppet:///modules/performanceplatform/home/vagrant/.bash_profile',
  }

  postgresql::server::role { 'stagecraft':
    createdb      => true,
    password_hash => postgresql_password('stagecraft', $stagecraft_password),
  }
}
