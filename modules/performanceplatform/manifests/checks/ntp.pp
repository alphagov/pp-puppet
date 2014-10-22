class performanceplatform::checks::ntp (
) {

  sensu::check { 'check_ntp':
    command  => '/etc/sensu/community-plugins/plugins/system/check-ntp.rb -w 100 -c 200',
    interval => '60',
    handlers => ['default']
  }

}
