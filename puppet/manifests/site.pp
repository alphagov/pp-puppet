node default {
    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
    }
    notify { 'Puppet is running on machine': }
}
