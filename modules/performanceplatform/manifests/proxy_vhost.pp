define performanceplatform::proxy_vhost(
  $port                = '80',
  $priority            = '10',
  $template            = 'nginx/vhost-proxy.conf.erb',
  $upstream_server     = 'localhost',
  $upstream_port       = '8080',
  $servername          = '',
  $serveraliases       = undef,
  $ssl                 = false,
  $ssl_port            = '443',
  $ssl_path            = $nginx::server::default_ssl_path,
  $ssl_cert            = $nginx::server::default_ssl_cert,
  $ssl_key             = $nginx::server::default_ssl_key,
  $ssl_redirect        = false,
  $magic               = '',
  $isdefaultvhost      = false,
  $proxy               = true,
  $forward_host_header = true,
  $client_max_body_size = '10m',
  $access_logs         = { '{name}.access.log' => '' },
  $error_logs          = { '{name}.error.log' => '' },
) {

  $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')
  $graphite_servername = regsubst($servername, '\.', '_', 'G')

  performanceplatform::graphite_check { "5xx_rate_${servername}":
    target   => "sumSeries(stats.nginx.${graphite_fqdn}.${graphite_servername}.http_5*)",
    warning  => '~:0',
    critical => '~:10',
    interval => '10',
  }

  performanceplatform::graphite_check { "4xx_rate_${servername}":
    target   => "sumSeries(stats.nginx.${graphite_fqdn}.${graphite_servername}.http_4*)",
    warning  => '~:0',
    critical => '~:10',
    interval => '10',
  }

  nginx::vhost::proxy { $name:
    port                 => $port,
    priority             => $priority,
    template             => $template,
    upstream_server      => $upstream_server,
    upstream_port        => $upstream_port,
    servername           => $servername,
    serveraliases        => $serveraliases,
    ssl                  => $ssl,
    ssl_port             => $ssl_port,
    ssl_path             => $ssl_path,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    ssl_redirect         => $ssl_redirect,
    magic                => $magic,
    isdefaultvhost       => $isdefaultvhost,
    proxy                => $proxy,
    forward_host_header  => $forward_host_header,
    client_max_body_size => $client_max_body_size,
    access_logs          => $access_logs,
    error_logs           => $error_logs,
  }

}
