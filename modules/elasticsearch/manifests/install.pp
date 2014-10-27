# == Class elasticsearch::install
#
# This installs elasticsearch package. It also installs estools.
#
# === Parameters
#
# [*version*]
#   The version of elasticsearch which will be installed. It is a required
#   parameter.
#
class elasticsearch::install(
  $version = undef,
){
  include elasticsearch::params

  if $version == undef {
    fail('You must provide an elasticsearch version for package installation')
  }

  ensure_packages(['python-pip'])

  package { $elasticsearch::params::package_name:
    ensure  => $version,
    notify  => Exec['disable-default-elasticsearch'],
  }

  # Disable the default elasticsearch setup, as we'll be installing an upstart
  # job to manage elasticsearch in elasticsearch::{config,service}
  exec { 'disable-default-elasticsearch':
    onlyif      => '/usr/bin/test -f /etc/init.d/elasticsearch',
    command     => "/etc/init.d/elasticsearch stop && \
          /bin/rm -f /etc/init.d/elasticsearch && \
          /usr/sbin/update-rc.d elasticsearch remove",
    refreshonly => true,
  }

  # Manage elasticsearch plugins, which are installed by elasticsearch::plugin
  file { '/usr/share/elasticsearch/plugins':
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['elasticsearch'],
  }

  file { '/var/run/elasticsearch':
    ensure => directory,
  }

  file { '/var/log/elasticsearch':
    ensure  => directory,
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    require => Package['elasticsearch'], # wait for package to create ES user.
  }

  # Install the estools package (which we maintain, see
  # https://github.com/alphagov/estools), which is used to install templates
  # and rivers, among other things.
  package { 'estools':
    ensure   => '1.0.3',
    provider => 'pip',
    require  => Package['python-pip'],
  }

}
