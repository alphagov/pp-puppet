# Class: performanceplatform::fail2ban
#
#
class performanceplatform::fail2ban {
    $whitelist_ips = hiera('whitelist_ips')
    class { 'fail2ban':
        jails_template => content('performanceplatform/jail.local.erb')
    }
}
