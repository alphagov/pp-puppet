class performanceplatform::checks::ntp (
) {

  sensu::check { "check_ntp":
    command  => '/etc/sensu/community-plugins/plugins/system/check-ntp.rb -w 2 -c 3',
    interval => 3600,
    handlers => ['default']
  }

}
