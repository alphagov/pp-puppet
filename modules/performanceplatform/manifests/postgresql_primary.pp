class performanceplatform::postgresql_primary {
  class { 'postgresql::globals':
    # Don't install from the postgresql PPA. See "postgresql::globals" @
    # See https://forge.puppetlabs.com/puppetlabs/postgresql#setup
    manage_package_repo => false,
    version             => '9.1',
  }->
  class { 'postgresql::server':
  }

  # Create stagecraft db
  postgresql::server::db { 'stagecraft':
    user     => 'stagecraft_user',
    password => postgresql_password('stagecraft_user', 'stagecraft_password'),
  }
}
