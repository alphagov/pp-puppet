define performanceplatform::checks::graphite (
  $target,
  $warning,
  $critical,
  $interval = 60,
  $handlers = undef,
  $below = false,
) {

  $check_data_path = '/etc/sensu/community-plugins/plugins/graphite/check-data.rb'
  $server_config = "-s graphite -u ${::basic_auth_username} -p ${::basic_auth_password}"

  if $below {
    $below_flag = '-b'
  } else {
    $below_flag = ''
  }

  $max_age = $interval * 2

  sensu::check { $name:
    command  => "${check_data_path} ${server_config} --age ${max_age} -t \"${target}\" -w \"${warning}\" -c \"${critical}\" ${below_flag} -n \"${name}\"",
    interval => $interval,
    handlers => $handlers,
    custom   => {
      graphite_url => "https://${::graphite_vhost}/render?target=${target}&from=-${interval}s",
    },
  }
}
