# === Parameters
#
# [*request_uuid*]
#   Optional boolean value. Whether to proxy_set_header the $request_uuid value or not.
#   If set, this can be used to trace a request through all the systems that collaborate
#   to service a single external request
#
define performanceplatform::gunicorn_app (
  $ensure                      = 'present',
  $description                 = $title,
  $port                        = undef,
  $workers                     = 4,
  $timeout                     = 30,
  $app_module                  = undef,
  $user                        = undef,
  $group                       = undef,
  $servername                  = $title,
  $serveraliases               = undef,
  $proxy_ssl                   = false,
  $add_header                  = undef,
  $client_max_body_size        = '10m',
  $is_django                   = false,
  $client_max_body_size        = '10m',
  $ssl_cert                    = hiera('public_ssl_cert'),
  $ssl_key                     = hiera('public_ssl_key'),
  $request_uuid                = false,
  $statsd_prefix               = $title,
  $capture_stderr              = false,
) {
  validate_bool($request_uuid)
  include nginx

  if $is_django {
    $proxy_append_forwarded_host = false
    $proxy_set_forwarded_host = true
  } else {
    $proxy_append_forwarded_host = true
    $proxy_set_forwarded_host = false
  }

  $config_path     = "/etc/gds/${title}"
  $app_path        = "/opt/${title}"
  $virtualenv_path = "${app_path}/shared/venv"

  performanceplatform::proxy_vhost { "${title}-vhost":
    ensure                      => $ensure,
    port                        => 80,
    upstream_port               => $port,
    servername                  => $servername,
    serveraliases               => $serveraliases,
    ssl                         => $proxy_ssl,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    proxy_append_forwarded_host => $proxy_append_forwarded_host,
    proxy_set_forwarded_host    => $proxy_set_forwarded_host,
    client_max_body_size        => $client_max_body_size,
    add_header                  => $add_header,
    request_uuid                => $request_uuid,
  }

  if $capture_stderr {
    $stderr_string = ' 2>&1'
  } else {
    $stderr_string = ''
  }

  performanceplatform::python_app { $title:
    ensure          => $ensure,
    app_path        => $app_path,
    virtualenv_path => $virtualenv_path,
    config_path     => $config_path,
    app_module      => $app_module,
    user            => $user,
    group           => $group,
    upstart_exec    => "${virtualenv_path}/bin/gunicorn -c ${config_path}/gunicorn ${app_module}${stderr_string}",
    upstart_desc    => $description,
  }

  file { "${config_path}/gunicorn":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    content => template('performanceplatform/gunicorn.erb')
  }
  file { "${config_path}/gunicorn.logging.conf":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    content => template('performanceplatform/gunicorn.logging.conf.erb')
  }
  logrotate::rule { "${title}-application":
    ensure       => $ensure,
    path         => "/opt/${title}/shared/log/*.log /opt/${title}/shared/log/*.log.json /var/log/${title}/*.log /var/log/${title}/*.log.json",
    rotate       => 30,
    rotate_every => 'day',
    missingok    => true,
    compress     => true,
    create       => true,
    create_mode  => '0640',
    create_owner => $user,
    create_group => $group,
    postrotate   => "initctl restart ${title}",
  }
}

