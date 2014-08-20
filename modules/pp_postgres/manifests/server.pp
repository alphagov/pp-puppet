class pp_postgres::server {
  Class['postgresql::globals'] -> Class['postgresql::server']
  class { 'postgresql::globals':
    # Don't install from the postgresql PPA. See "postgresql::globals" @
    # See https://forge.puppetlabs.com/puppetlabs/postgresql#setup
    manage_package_repo => false,
    version             => '9.1',
  }->
  class { 'postgresql::server':
  }
}