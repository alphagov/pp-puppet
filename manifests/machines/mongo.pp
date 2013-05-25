class machines::mongo inherits machines::base {
    notify { 'Included the mongo class': }
    ufw::allow { "allow-mongo-from-backend":
        port => 27017,
        ip   => 'any',
        from => $networks['backend']
    }
    class { 'mongodb':
        enable_10gen => true,
        replSet      => 'production'
    }
}
