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
  $proxy_append_forwarded_host = false,
  $proxy_set_forwarded_host = false,
  $forward_host_header = true,
  $client_max_body_size = '10m',
  $access_logs          = { '{name}.access.log' => '' },
  $error_logs           = { '{name}.error.log' => '' },
  $five_critical        = '~:0',
  $five_warning         = '~:0',
  $four_critical        = '~:0',
  $four_warning         = '~:0',
  $sensu_check          = true,
  $pp_only_vhost        = false,
  $denied_http_verbs    = [],
) {

  $graphite_servername = regsubst($servername, '\.', '_', 'G')

  if $sensu_check {
    performanceplatform::checks::graphite { "5xx_rate_${servername}":
      # Total number of 5xx requests over the last minute
      target            => "hitcount(transformNull(stats.nginx.${::hostname}.${graphite_servername}.http_5*,0),'1min')",
      warning           => $five_warning,
      critical          => $five_critical,
      interval          => 60,
      ignore_no_data    => true,
      ignore_http_error => true,
      handlers          => ['default'],
    }

    performanceplatform::checks::graphite { "4xx_rate_${servername}":
      # Total number of 4xx requests over the last minute
      target            => "hitcount(transformNull(stats.nginx.${::hostname}.${graphite_servername}.http_4*,0),'1min')",
      warning           => $four_warning,
      critical          => $four_critical,
      interval          => 60,
      ignore_no_data    => true,
      ignore_http_error => true,
      handlers          => ['default'],
    }
  } else {
    sensu::check { "5xx_rate_${servername}":
      command => "",
    }
    sensu::check { "4xx_rate_${servername}":
      command => "",
    }
  }

  # Restrict access beyond GDS ips
  if $pp_only_vhost {
    $gds_only = hiera('pp_only_vhost')
    $magic_with_pp_only = "${magic}${gds_only}"
  } else {
    $magic_with_pp_only = $magic
  }

  logrotate::rule { "${title}-json-logs":
    path         => "/var/log/nginx/${servername}.*.log.json",
    rotate       => 30,
    rotate_every => 'day',
    missingok    => true,
    compress     => true,
    create       => true,
    create_mode  => '0640',
    create_owner => $::user,
    create_group => $::group,
    postrotate   => 'service nginx rotate',
  }

  nginx::vhost::proxy { $name:
    port                        => $port,
    priority                    => $priority,
    template                    => $template,
    upstream_server             => $upstream_server,
    upstream_port               => $upstream_port,
    servername                  => $servername,
    serveraliases               => $serveraliases,
    ssl                         => $ssl,
    ssl_port                    => $ssl_port,
    ssl_path                    => $ssl_path,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_redirect                => $ssl_redirect,
    magic                       => $magic_with_pp_only,
    isdefaultvhost              => $isdefaultvhost,
    proxy                       => $proxy,
    proxy_magic                 => $proxy_magic,
    proxy_append_forwarded_host => $proxy_append_forwarded_host,
    proxy_set_forwarded_host    => $proxy_set_forwarded_host,
    forward_host_header         => $forward_host_header,
    client_max_body_size        => $client_max_body_size,
    access_logs                 => $access_logs,
    error_logs                  => $error_logs,
    denied_http_verbs           => $denied_http_verbs,
  }

}
