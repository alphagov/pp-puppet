class machines::base {
    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
    }
    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
FACTER_machine_class=${machine_class}
"
    }
    include ufw
    ufw::allow { "allow-ssh-from-all":
        port => 22,
        ip   => 'any'
    }
    # Manage /etc/hosts
    create_resources( 'host', hiera_hash("hosts") )
    # Create user accounts
    create_resources( 'account', hiera("accounts") )
}
