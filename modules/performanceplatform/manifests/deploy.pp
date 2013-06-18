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
    }
}
