# Base resources for all PP machines
class performanceplatform::base {
    include apt
    include collectd
    include collectd::plugin::write_graphite
    include gcc
    include harden
    include ntp
    include python
    include rsyslog::client
    include ssh::server
    include tmux
    include ufw

    stage { 'system':
      before => Stage['main'],
    }

    class { [ 'performanceplatform::dns',
              'performanceplatform::hosts' ]:
      stage => system,
    }

    class {'gstatsd': require => Class['python::install'] }

    apt::ppa { 'ppa:gds/govuk': }

    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
        require => Apt::Ppa['ppa:gds/govuk'],
    }
    $machine_role = regsubst($::hostname, '^(.*)-\d$', '\1')
    $environment = hiera('environment')
    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
FACTER_machine_role=${machine_role}
FACTER_machine_environment=${environment}
"
    }
    file {'/etc/gds':
        ensure => directory,
    }
    # Make sure we are in UTC
    file { '/etc/localtime':
        source => '/usr/share/zoneinfo/UTC'
    }
    file { '/etc/timezone':
        content => 'UTC'
    }
    group { 'gds': ensure => present }
    file { '/etc/sudoers.d/gds':
        ensure  => present,
        mode    => '0440',
        content => '%gds ALL=(ALL) NOPASSWD: ALL
'
    }
    file { '/bin/su':
        ensure => present,
        mode   => '4750',
        owner  => 'root',
        group  => 'gds',
    }

    package {'sensu-plugin':
      ensure   => installed,
      provider => gem
    }

    vcsrepo { '/etc/sensu/community-plugins':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/sensu/sensu-community-plugins.git',
      revision => '4e4f279bd3a16330ffc0083cc1494e7da878e730',
    }

}
