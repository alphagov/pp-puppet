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
    content   => 'betademo:cBxAp7qb7cNXc', # nottobes
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

  logstash::input::lumberjack { 'lumberjack':
    format          => 'json',
    type            => 'lumberjack',
    port            => 3456,
    ssl_certificate => 'puppet:///modules/performanceplatform/logstash.pub',
    ssl_key         => 'puppet:///modules/performanceplatform/logstash.key',
  }

  # Ensure the monitoring box is not a syslog server so that logstash
  # can connect to the syslog port (514)
  file { "/etc/rsyslog.d/server.conf":
    ensure => absent,
  }

  # Ensure monitoring is no longer responsible for running elasticsearch
  class { '::elasticsearch::install':
    version => absent,
  }


  logstash::input::syslog { 'logstash-syslog':
    type => "syslog",
    tags => ["syslog"],
  }

  logstash::filter::date { 'varnish-timestamp-fix':
    type  => 'lumberjack',
    tags  => [ 'varnish' ],
    match => [ 'timestamp', '[dd/MMM/YYYY:HH:mm:ss Z]' ],
  }

  logstash::filter::mutate { 'nginx-token-fix':
    type => 'lumberjack',
    tags => [ 'nginx' ],
    gsub => [
      '@source_host', '\.', '_',
      'server_name',  '\.', '_',
    ],
  }

  logstash::filter::grep { 'ignore_backdrop_status_request':
    match  => {
      '@message' => "\"(request|response): GET .*/_status( - 200 OK)?\"",
    },
    negate => true,
    order  => 20,
  }
  logstash::filter::grep { 'ignore_gunicorn_status_request':
    match  => {
      '@message' => "\\\"GET /_status HTTP/1.0\\\"",
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
  }

  logstash::output::elasticsearch_http { 'elasticsearch':
    host => 'elasticsearch',
  }

  sensu::check { 'logstash_is_down':
    command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p logstash -W 1 -C 1',
    interval => 60,
    handlers => 'pagerduty',
  }

  sensu::check { 'elasticsearch_is_out_of_memory':
    ensure => absent,
    command => '',
  }

  $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')

  performanceplatform::graphite_check { "check_low_disk_space_elasticsearch":
    target   => "collectd.${graphite_fqdn}.df-mnt-data-elasticsearch.df_complex-free",
    warning  => '4000000000:', # A little less than 4 gig
    critical => '1000000000:',  # A little less than 1 gig
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
