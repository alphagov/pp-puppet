class performanceplatform::deploy (
    $vpn_gateway  = undef,
    $vpn_user     = undef,
    $vpn_password = undef,
    $basic_auth   = undef,
) {
    #Only phone home if the vpn credentials are set
    if ( $vpn_gateway and ( $vpn_user and $vpn_password )) {
        class { 'openconnect':
            gateway   => $vpn_gateway,
            user      => $vpn_user,
            password  => $vpn_password,
        }
    }
    if ($basic_auth) {
        file { '/etc/nginx/htpasswd.pp':
            ensure  => present,
            content => $basic_auth,
            require => Package['nginx'],
        }
        file { '/etc/nginx/conf.d/basic_auth.conf':
            ensure  => present,
            content => 'auth_basic "Enter username/password";
auth_basic_user_file /etc/nginx/htpasswd.pp;',
            require => File['/etc/nginx/htpasswd.pp'],
            notify  => Service['nginx'],
        }
    }

    group { 'jenkins':
          ensure  => present,
          require => Class['jenkins'],
    }

          # The pam_auth plugin requires Jenkins to be in the shadow group
    user { 'jenkins':
        ensure     => present,
        groups     => ['jenkins', 'shadow'],
        home       => '/var/lib/jenkins',
        managehome => true,
        shell      => '/bin/bash',
        require    => Group['jenkins'],
    }
}
