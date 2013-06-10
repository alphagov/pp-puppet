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

    # Ensure that the govuk ppa is installed before any other packages are installed
    Apt::Ppa['ppa:gds/govuk'] -> Package <| title != 'python-software-properties' and title != 'software-properties-common' |>

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
    
    # -- install packages required by gems
    package { [ 'build-essential', 'libxslt-dev', 'libxml2-dev' ] :
        ensure => present,
    }

    # -- install packages required by rails runtime
    package { [ 'nodejs' ]:
        ensure => present,
    }

    limelight::app {'limelight':
        port        => 3040,
        user        => $user,
        group       => $group,
        domain_name => hiera('domain_name'),
    }
}

