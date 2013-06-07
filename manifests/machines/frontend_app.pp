# A frontend application server
class machines::frontend_app inherits machines::base {
    ufw::allow { 'allow-http-from-frontend-lb-1':
        port => 80,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    ufw::allow { 'allow-https-from-frontend-lb-1':
        port => 443,
        ip   => 'any',
        from => $hosts['frontend-lb-1.frontend']['ip'],
    }
    
    # create deploy user
    $user = 'deploy'
    $group = 'deploy'

    user { $user:
        ensure => present,
        shell  => "/bin/bash",
        managehome => true,
    }

    # install govuk deb repository - do this for all machines
    class { 'apt': }
    apt::ppa { 'ppa:gds/govuk': }

    # For librarian-puppet
    package { ['ruby1.9.1', 'ruby1.9.1-dev']:
        ensure => $version,
    }

    # install rbenv & ruby
    include rbenv

    rbenv::version { '1.9.3-p392':
        bundler_version => '1.3.5'
    }
    rbenv::alias { '1.9.3':
        to_version => '1.9.3-p392',
    }


    # create limelight environment
    include nginx::server
    nginx::vhost::proxy { 'limelight-vhost':
        port            => 80,
        servername      => join(['limelight',hiera('domain_name')],'.'),
        ssl             => false,
        upstream_port   => 3040,
    }
    
    # -- install packages required by gems
    package { [ 'build-essential', 'libxslt-dev', 'libxml2-dev' ] :
        ensure => present,
    }

    # -- install packages required by rails runtime
    package { [ 'nodejs' ]:
        ensure => present,
    }

    $appname = 'limelight'

    $app_path = "/opt/${appname}"
    $log_path = "/var/log/${appname}"
    $config_path = "/etc/opt/${appname}"

    file { ["$app_path", "$log_path", "$config_path"]:
        ensure => directory,
        owner  => $user,
        group  => $group,
    }  

    include upstart
    upstart::job { "$appname":
        description   => $appname,
        respawn       => true,
        respawn_limit => '5 10',
        user          => $user,
        group         => $group,
        chdir         => $app_path,
        environment   => {
            'GOVUK_ENV' => 'production',
            'RAILS_ENV' => 'production',
            'GOVUK_APP_DOMAIN' => 'production.alphagov.co.uk',
            'BACKDROP_URL' => 'read.backdrop',
        },
        exec          => 'bundle exec unicorn_rails -p 3040',
    }
}

