class performanceplatform::checks::ssl () {
  $check_http_path = '/etc/sensu/community-plugins/plugins/http/check-http.rb'

  $domain_name = hiera('domain_name')

  sensu::check { 'ssl_expiry_check':
    command  => "${check_http_path} -u https://www.${domain_name} -e 30",
    interval => 120,
    handlers => ['default'],
  }

}
