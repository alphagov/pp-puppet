define performanceplatform::graphite_check(
  $target,
  $warning,
  $critical,
  $interval = 60,
  $handlers = undef,
  $ignore_no_data = false,
) {

  $check_data_path = '/etc/sensu/community-plugins/plugins/graphite/check-data.rb'
  $server_config = '-s graphite -u betademo -p nottobes'

  if $ignore_no_data {
    $flags = '--ignore-no-data'
  } else {
    $flags = ''
  }

  $max_age = $interval * 2

  sensu::check { $name:
    command  => "${check_data_path} ${server_config} ${flags} --age ${max_age} -t \"${target}\" -w \"${warning}\" -c \"${critical}\" -n \"${name}\"",
    interval => $interval,
    handlers => $handlers,
    custom   => {
      graphite_url => "https://${::graphite_vhost}/render?target=${target}&from=-${interval}s",
    },
  }
}
