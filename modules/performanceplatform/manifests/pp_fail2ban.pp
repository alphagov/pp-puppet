# Class: performanceplatform::fail2ban
#
#
class performanceplatform::pp_fail2ban {
    $whitelist_ips = hiera('fail2ban::whitelist_ips')
    class { 'fail2ban':
        source         => 'puppet:///modules/performanceplatform/fail2ban.local',
        jails_config   => 'file',
        jails_template => 'performanceplatform/jail.local.erb',
    }
}
