class machine_classes::base {
    exec { 'apt-get-update':
        command => '/usr/bin/apt-get update || true',
    }
    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
FACTER_machine_class=${machine_class}
"
    }
}
