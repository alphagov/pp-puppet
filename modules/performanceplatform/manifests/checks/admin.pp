class performanceplatform::checks::admin () {
  $check_http_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

  sensu::check { 'admin_status_check':
    command  => "${check_http_path} -u http://localhost:3070/_status",
    interval => 120,
    handlers => ['default'],
  }
}
