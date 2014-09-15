class performanceplatform::checks::ssl () {
  $check_https_path = '/etc/sensu/community-plugins/plugins/ssl/check-ssl-cert.rb'

  $domain_name = hiera('domain_name')

  sensu::check { 'ssl_expiry_check':
    command  => "${check_https_path} -h www.${domain_name} -p 443 -c 30 -w 40",
    interval => 86400,
    handlers => ['default'],
  }

}
