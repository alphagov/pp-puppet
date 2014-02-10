class performanceplatform::postgresql_primary (
  $stagecraft_password
) {
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
    user     => 'stagecraft',
    password => postgresql_password('stagecraft', $stagecraft_password),
  }

  # Allow access to stagecraft from performance platform cluster
  postgresql::server::pg_hba_rule { 'stagecraft':
    type        => 'host',
    database    => 'stagecraft',
    user        => 'stagecraft',
    auth_method => 'md5',
    address     => '172.27.1.1/24',
  }
}
