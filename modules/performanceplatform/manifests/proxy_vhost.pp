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
  $proxy_magic         = '',
  $forward_host_header = true,
  $client_max_body_size = '10m',
  $access_logs          = { '{name}.access.log' => '' },
  $error_logs           = { '{name}.error.log' => '' },
  $five_critical        = '~:0',
  $five_warning         = '~:0',
  $four_critical        = '~:0',
  $four_warning         = '~:0',
  $sensu_check          = true,
) {

  $graphite_servername = regsubst($servername, '\.', '_', 'G')

  if $sensu_check {
    performanceplatform::graphite_check { "5xx_rate_${servername}":
      target            => "keepLastValue(movingAverage(sumSeries(stats.nginx.${::hostname}.${graphite_servername}.http_5*),60))",
      warning           => $five_warning,
      critical          => $five_critical,
      interval          => 60,
      ignore_no_data    => true,
      ignore_http_error => true,
    }

    performanceplatform::graphite_check { "4xx_rate_${servername}":
      target            => "keepLastValue(movingAverage(sumSeries(stats.nginx.${::hostname}.${graphite_servername}.http_4*),60))",
      warning           => $four_warning,
      critical          => $four_critical,
      interval          => 60,
      ignore_no_data    => true,
      ignore_http_error => true,
    }
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
    proxy_magic          => $proxy_magic,
    forward_host_header  => $forward_host_header,
    client_max_body_size => $client_max_body_size,
    access_logs          => $access_logs,
    error_logs           => $error_logs,
  }

}
