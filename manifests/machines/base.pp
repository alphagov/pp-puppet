# Base class inherited by all machines
class machines::base {
    # Store the list of hosts for use later
    $hosts = hiera('hosts')
    $networks = hiera('networks')
    $environment = hiera('environment')

    # install govuk deb repository
    class { 'apt': }
    apt::ppa { 'ppa:gds/govuk': }

    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
        require => Apt::Ppa['ppa:gds/govuk'],
    }

    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
FACTER_machine_class=${::machine_class}
"
    }
    file {'/etc/gds':
        ensure => directory,
    }
    package {
      [
        'curl',
        'htop',
        'vim'
      ]:
      ensure => installed
    }
    # Default the firewall to closed
    include ufw
    # Open up SSH everywhere in development
    if $environment == 'development' {
        # This is necessary for Vagrant ssh to work
        ufw::allow { 'allow-ssh-from-anywhere':
            port => 22,
            ip   => 'any',
        }
    } else {
        # Default the firewall to closed
        ufw::allow { 'allow-ssh-from-jumpbox-1':
            port => 22,
            ip   => 'any',
            from => $hosts['jumpbox-1.management']['ip'],
        }
    }

    # Secure SSHd to prevent root login and only allow keys
    include ssh::server

    # Manage /etc/hosts
    create_resources( 'host', hiera_hash('hosts') )

    # Create user accounts
    create_resources( 'account', hiera('accounts') )
}
