# Class: performanceplatform::fail2ban
#
#
class performanceplatform::fail2ban {
    # TODO - shove hierdata ref in here
    # $whitelistips = hiera('some_value_you_have_put_in_common.yaml', '127.0.0.1')
    class { 'fail2ban':
        # TODO make this template
        jails_template => content('performanceplatform/jail.local.erb')

      # jails_config => 'file',
      # jails_source => 'puppet:///modules/performanceplatform/jail.local'
    }
}
