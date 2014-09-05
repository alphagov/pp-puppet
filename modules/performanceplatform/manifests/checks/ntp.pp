class performanceplatform::checks::ntp (
) {

  sensu::check { 'check_ntp':
    command  => '/etc/sensu/community-plugins/plugins/system/check-ntp.rb -w 10 -c 100',
    interval => '60',
    handlers => ['default']
  }

}
