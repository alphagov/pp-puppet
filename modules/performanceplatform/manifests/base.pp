# Base resources for all PP machines
class performanceplatform::base {
    stage { 'system':
        before => Stage['main'],
    }

    class { [ 'performanceplatform::dns',
              'performanceplatform::hosts' ]:
        stage => system,
    }

    class {'gstatsd': require => Class['python::install'] }

    $ppas = hiera_array('ppas', [])
    apt::ppa { $ppas: }

    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
        require => Apt::Ppa['ppa:gds/performance-platform'],
    }
    $machine_role = regsubst($::hostname, '^(.*)-\d$', '\1')

    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
FACTER_machine_role=${machine_role}
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

    Package['sensu-plugin'] -> Class['sensu']

    vcsrepo { '/etc/sensu/community-plugins':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/alphagov/sensu-community-plugins.git',
        revision => '86baac527cee804e6c0e795edf1d77bd85e5b355',
    }

}
