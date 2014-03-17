define performanceplatform::gunicorn_app (
  $description = $title,
  $port        = undef,
  $workers     = 4,
  $timeout     = 30,
  $app_module  = undef,
  $user        = undef,
  $group       = undef,
  $client_max_body_size = '10m',
  $is_django   = false,
) {
  # app_path is defined here so that the virtualenv can be
  # created in the correct place
  $app_path        = "/opt/${title}"
  $config_path     = "/etc/gds/${title}"
  $virtualenv_path = "${app_path}/shared/venv"

  if $is_django {
    $proxy_append_forwarded_host = false
    $proxy_set_forwarded_host = true
  } else {
    $proxy_append_forwarded_host = true
    $proxy_set_forwarded_host = false
  }

  performanceplatform::app { $title:
    port                        => $port,
    workers                     => $workers,
    app_module                  => $app_module,
    user                        => $user,
    group                       => $group,
    app_path                    => $app_path,
    config_path                 => $config_path,
    upstart_desc                => $description,
    upstart_exec                => "${virtualenv_path}/bin/gunicorn -c ${config_path}/gunicorn ${app_module}",
    proxy_append_forwarded_host => $proxy_append_forwarded_host,
    proxy_set_forwarded_host    => $proxy_set_forwarded_host,
    client_max_body_size        => $client_max_body_size,
  }

  python::virtualenv { $virtualenv_path:
    ensure     => present,
    version    => '2.7',
    systempkgs => false,
    owner      => $user,
    group      => $group,
    require    => File["${app_path}/shared"],
  }

  file { "${config_path}/gunicorn":
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('performanceplatform/gunicorn.erb')
  }
  file { "${config_path}/gunicorn.logging.conf":
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('performanceplatform/gunicorn.logging.conf.erb')
  }
  logrotate::rule { "${title}-application":
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

