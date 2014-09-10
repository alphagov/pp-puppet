class performanceplatform::deploy (
    $vpn_url           = undef,
    $vpn_user          = undef,
    $vpn_pass          = undef,
    $basic_auth        = undef,
    $jenkins_key       = undef,
    $jenkins_publickey = undef,
) {
    #Only phone home if the vpn credentials are set
    if ( $vpn_url and ( $vpn_user and $vpn_pass )) {
        class { 'openconnect':
            url  => $vpn_url,
            user => $vpn_user,
            pass => $vpn_pass,
        }
    }
    if ($basic_auth) {
        file { '/etc/nginx/htpasswd.pp':
            ensure  => present,
            content => $basic_auth,
            require => Package['nginx-extras'],
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
        file { '/var/lib/jenkins/.bash_profile':
          source  => 'puppet:///modules/performanceplatform/jenkins-bash_profile',
          owner   => 'jenkins',
          group   => 'jenkins',
          mode    => '0700',
          require => Class['jenkins']
        }
    }
}
