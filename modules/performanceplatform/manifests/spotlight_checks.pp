class performanceplatform::spotlight_checks () {
  $check_http_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

  sensu::check { 'spotlight_status_check':
    require  => Class['Spotlight::App'],
    command  => "${check_http_path} -u http://localhost:${spotlight::app::port}/_status",
    interval => 120,
    handlers => ['default'],
  }
}
