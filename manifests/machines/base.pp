# Base class inherited by all machines
class machines::base {
    # Store the list of hosts for use later
    $hosts = hiera('hosts')
    $environment = hiera('environment')
    # Manage /etc/hosts
    create_resources( 'host', hiera_hash('hosts') )
    # Create user accounts
    create_resources( 'account', hiera_hash('accounts') )
    # Install packages
    create_resources( 'package', hiera_hash('system_packages') )
    # Firewall rules
    create_resources( 'ufw::allow', hiera_hash('ufw_rules') )
    # Create nginx proxies
    $vhost_proxies = hiera_hash( 'vhost_proxies', {} )
    if !empty($vhost_proxies) {
        create_resources( 'nginx::vhost::proxy', $vhost_proxies )
    }
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
}
