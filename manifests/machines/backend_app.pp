# Setup a backend application server
class machines::backend_app inherits machines::base {
    ufw::allow { 'allow-http-from-frontend-app-1':
        port => 80,
        ip   => 'any',
        from => $hosts['frontend-app-1.frontend']['ip'],
    }
    ufw::allow { 'allow-http-from-frontend-app-2':
        port => 80,
        ip   => 'any',
        from => $hosts['frontend-app-2.frontend']['ip'],
    }

    user { 'deploy':
        ensure => present,
    }

    class { 'python':
        version    => '2.7',
        dev        => true,
        virtualenv => true,
    }

    backdrop::app {'read.backdrop':
        port        => 3038,
        app_module  => 'backdrop.read.api:app',
        user        => 'deploy',
        group       => 'deploy',
    }

    backdrop::app {'write.backdrop':
        port        => 3039,
        app_module  => 'backdrop.write.api:app',
        user        => 'deploy',
        group       => 'deploy',
    }

}
