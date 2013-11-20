class performanceplatform::monitoring (
) {

  file { '/etc/apache2/run':
    ensure  => link,
    target  => '/var/run/apache2',
    require => Package[$::graphite::params::apache_pkg],
    notify  => Service['apache2'],
  }

  file { '/etc/nginx/htpasswd':
    ensure    => present,
    content   => "${::basic_auth_username}:${::basic_auth_password_hashed}",
    subscribe => Service['nginx'],
  }

  package { 'redphone':
    ensure   => installed,
    provider => 'gem',
    require  => Package['ruby1.9.1-dev'],
  }

  Class['redis'] -> Class['sensu']
  Class['rabbitmq'] -> Class['sensu']
  Package['redphone'] -> Class['sensu']

  rabbitmq_user { 'sensu':
    ensure   => present,
    password => $::rabbitmq_sensu_password,
    admin    => true,
    provider => 'rabbitmqctl',
    notify   => Class['sensu'],
  }

  rabbitmq_vhost { '/sensu':
    ensure   => present,
    provider => 'rabbitmqctl',
    notify   => Class['sensu'],
  }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    provider             => 'rabbitmqctl',
    notify               => Class['sensu'],
  }

  logstash::input::lumberjack { 'lumberjack-agent':
    format          => 'json',
    type            => 'lumberjack',
    port            => 3456,
    ssl_certificate => 'puppet:///modules/performanceplatform/logstash.pub',
    ssl_key         => 'puppet:///modules/performanceplatform/logstash.key',
    instances       => [ 'agent' ],
  }

  logstash::input::lumberjack { 'lumberjack-agent-1':
    format          => 'json',
    type            => 'lumberjack',
    port            => 3457,
    ssl_certificate => 'puppet:///modules/performanceplatform/logstash.pub',
    ssl_key         => 'puppet:///modules/performanceplatform/logstash.key',
    instances       => [ 'agent-1' ],
  }

  # Ensure the monitoring box is not a syslog server so that logstash
  # can connect to the syslog port (514)
  file { "/etc/rsyslog.d/server.conf":
    ensure => absent,
  }


  logstash::input::syslog { 'logstash-syslog':
    type => "syslog",
    tags => ["syslog"],
    instances => [ 'agent', 'agent-1' ],
  }

  logstash::filter::date { 'varnish-timestamp-fix':
    type  => 'lumberjack',
    tags  => [ 'varnish' ],
    match => [ 'timestamp', '[dd/MMM/YYYY:HH:mm:ss Z]' ],
    instances => [ 'agent', 'agent-1' ],
  }

  logstash::filter::mutate { 'nginx-token-fix':
    type => 'lumberjack',
    tags => [ 'nginx' ],
    gsub => [
      '@source_host', '\.', '_',
      'server_name',  '\.', '_',
    ],
    instances => [ 'agent', 'agent-1' ],
  }

  logstash::filter::grep { 'ignore_backdrop_status_request':
    match  => {
      '@message' => "\\\"(request|response): GET .*/_status( - 200 OK)?\\\"",
    },
    negate => true,
    order  => 20,
  }
  logstash::filter::grep { 'ignore_gunicorn_status_request':
    match  => {
      '@message' => "\\\\\\\"GET /_status HTTP/1.0\\\\\\\"",
    },
    negate => true,
    order  => 20,
  }

  logstash::output::statsd { 'statsd':
    type      => 'lumberjack',
    tags      => [ 'nginx' ],
    count     => { '%{server_name}.http_%{status}' => 1 },
    timing    => {
      '%{server_name}.request_time' => '%{request_time}'
    },
    namespace => 'nginx',
    instances => [ 'agent', 'agent-1' ],
  }

  logstash::output::elasticsearch_http { 'elasticsearch':
    host => 'elasticsearch',
    instances => [ 'agent', 'agent-1' ],
  }

  sensu::check { 'logstash_is_down':
    command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p logstash -W 1 -C 1',
    interval => 60,
    handlers => 'pagerduty',
  }

  $pagerduty_api_key = hiera('pagerduty_api_key', undef)

  if $pagerduty_api_key != undef {
    sensu::handler { 'pagerduty':
      command    => '/etc/sensu/community-plugins/handlers/notification/pagerduty.rb',
      config     => {
        api_key  => $pagerduty_api_key,
      }
    }
  }

}
