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
    include nginx::server
    user { 'deploy':
        ensure => present,
    }
    class { 'python':
        version    => '2.7',
        dev        => true,
        virtualenv => true,
    }
    file { '/var/virtualenvs':
        ensure => directory,
        owner  => 'deploy',
    }
    include upstart
    file { '/etc/gds':
        ensure => directory,
        owner  => 'deploy',
    }
    backdrop::app {'read.backdrop':
        port       => 3038,
        app_module => 'backdrop.read.api:app',
    }
    backdrop::app {'write.backdrop':
        port       => 3039,
        app_module => 'backdrop.write.api:app',
    }


    # Manual deployment steps
    # 
    # Copy backdrop source to /opt/read.backdrop and /opt/write.backdrop
    # Install python dependencies (from project root)
    #    sudo -u deploy /var/virtualenvs/{title}/bin/pip install -r requirements.txt
    # Install configuration files
    #    I'd really like to get these moved out of the package hierarchy
    #    Copy from alphagov-deployment to /opt/{title}/backdrop/{read,write}/config/production.py
    # For write.backdrop
    #    sudo -u deploy backdrop/write/config/development_tokens.py backdrop/write/config/tokens.py
}
