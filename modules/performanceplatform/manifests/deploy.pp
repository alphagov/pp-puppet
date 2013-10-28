class performanceplatform::deploy (
    $vpn_gateway       = undef,
    $vpn_user          = undef,
    $vpn_password      = undef,
    $basic_auth        = undef,
    $jenkins_key       = undef,
    $jenkins_publickey = undef,
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
    }
    if ($jenkins_key) {
        # Install the SSH private key for Jenkins
        file { '/var/lib/jenkins/.ssh':
            ensure  => directory,
            mode    => '0700',
            owner   => 'jenkins',
            group   => 'jenkins',
            require => Class['jenkins'],
        }
        file { '/var/lib/jenkins/.ssh/id_rsa':
            ensure  => present,
            content => $jenkins_key,
            mode    => '0600',
            owner   => 'jenkins',
            group   => 'jenkins',
            require => File['/var/lib/jenkins/.ssh'],
        }
        if ($jenkins_publickey) {
          file { '/var/lib/jenkins/.ssh/id_rsa.pub':
              ensure  => present,
              content => $jenkins_publickey,
              mode    => '0600',
              owner   => 'jenkins',
              group   => 'jenkins',
              require => File['/var/lib/jenkins/.ssh'],
          }
        }
        file { '/var/lib/jenkins/.fabricrc':
            ensure  => present,
            content => 'user = deploy
',
            mode    => '0644',
            owner   => 'jenkins',
            group   => 'jenkins',
            require => Class['jenkins'],
        }
        file { '/var/lib/jenkins/.bashrc':
          source  => 'puppet:///modules/performanceplatform/jenkins-bashrc',
          owner   => 'jenkins',
          group   => 'jenkins',
          mode    => '0700',
          require => Class['jenkins']
        }
    }
}
