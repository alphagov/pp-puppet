define performanceplatform::checks::graphite (
  $target,
  $warning,
  $critical,
  $interval = 60,
  $handlers = undef,
  $ignore_no_data = false,
  $ignore_http_error = false,
) {

  $check_data_path = '/etc/sensu/community-plugins/plugins/graphite/check-data.rb'
  $server_config = "-s ${::graphite_vhost} -u ${::basic_auth_username} -p ${::basic_auth_password}"

  if $ignore_no_data {
    $ignore_no_data_flag = '--ignore-no-data'
  } else {
    $ignore_no_data_flag = ''
  }

  if $ignore_http_error {
    $ignore_http_error_flag = '--ignore-http-error'
  } else {
    $ignore_http_error_flag = ''
  }


  $max_age = $interval * 2

  sensu::check { $name:
    command  => "${check_data_path} ${server_config} ${ignore_no_data_flag} ${ignore_http_error_flag} --age ${max_age} -t \"${target}\" -w \"${warning}\" -c \"${critical}\" -n \"${name}\"",
    interval => $interval,
    handlers => $handlers,
    custom   => {
      graphite_url => "https://${::graphite_vhost}/render?target=${target}&from=-${interval}s",
    },
  }
}
