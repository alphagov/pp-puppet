define performanceplatform::graphite_check(
  $target,
  $warning,
  $critical,
  $interval = '60',
) {

    $check_data_path = '/etc/sensu/community-plugins/plugins/graphite/check-data.rb'
    $server_config = '-s graphite -u betademo -p nottobes'

    sensu::check { $name:
      command  => "${check_data_path} ${server_config} -t \"${target}\" -w \"${warning}\" -c \"${critical}\" -n \"${name}\"",
      interval => $interval,
      custom         => {
        graphite_url => "https://${::graphite_vhost}/render?target=${target}&from=-10min",
      },
    }

}
