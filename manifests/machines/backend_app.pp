# Setup a backend application server
class machines::backend_app inherits machines::base {
    ufw::allow { 'allow-http-from-backend-lb-1':
        port => 80,
        ip   => 'any',
        from => $hosts['backend-lb-1.backend']['ip'],
    }
    ufw::allow { 'allow-https-from-backend-lb-1':
        port => 443,
        ip   => 'any',
        from => $hosts['backend-lb-1.backend']['ip'],
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
        domain_name => hiera('domain_name'),
        user        => 'deploy',
        group       => 'deploy',
    }

    backdrop::app {'write.backdrop':
        port        => 3039,
        app_module  => 'backdrop.write.api:app',
        domain_name => hiera('domain_name'),
        user        => 'deploy',
        group       => 'deploy',
    }

}
