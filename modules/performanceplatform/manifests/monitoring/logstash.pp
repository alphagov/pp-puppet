class performanceplatform::monitoring::logstash (
  $config = {},
  $init_defaults_file = 'puppet:///modules/performanceplatform/etc/sysconfig/logstash.dev.defaults',
) {

  apt::source { 'logstash':
    location    => 'http://packages.elasticsearch.org/logstash/1.4/debian',
    release     => 'stable',
    repos       => 'main',
    key         => 'D88E42B4',
    key_source  => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    include_src => false,
  }

  class { '::logstash':
    version            => '1.4.2-1-2c0f5a1',
    init_defaults_file => $init_defaults_file,
    install_contrib    => true,
    contrib_version    => '1.4.2-1-efd53ef',
    require            => [Apt::Source['logstash'], Class['::java']],
  }

  file {
    '/etc/logstash/lumberjack.pub':
      source => 'puppet:///modules/performanceplatform/logstash.pub',
      notify => Class['::logstash::service'];
    '/etc/logstash/lumberjack.key':
      source => 'puppet:///modules/performanceplatform/logstash.key',
      notify => Class['::logstash::service'];
  }

  create_resources('logstash::configfile', $config)

  logrotate::rule { 'logstash-rotate':
    path         => '/var/log/logstash/*.log',
    rotate       => 30,
    rotate_every => 'day',
    missingok    => true,
    compress     => true,
    create       => true,
    create_mode  => '0640',
    postrotate   => 'service logstash restart',
  }

  sensu::check { 'logstash_is_down':
    command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p logstash -C 1 -W 1',
    interval => 60,
    handlers => ['default'],
  }

}
