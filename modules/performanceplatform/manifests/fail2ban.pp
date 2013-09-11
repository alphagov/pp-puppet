# Class: performanceplatform::fail2ban
#
#
class performanceplatform::fail2ban {
    # TODO - shove hierdata ref in here
    $whitelist_ips = hiera('environment.yaml', '127.0.0.1')
    class { 'fail2ban':
        jails_template => content('performanceplatform/jail.local.erb')

      # jails_config => 'file',
      # jails_source => 'puppet:///modules/performanceplatform/jail.local'
    }
}
