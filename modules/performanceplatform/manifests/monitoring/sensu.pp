class performanceplatform::monitoring::sensu (
) {

  Class['redis'] -> Class['::sensu']
  Class['rabbitmq'] -> Class['::sensu']
  Package['redphone'] -> Class['::sensu']

  rabbitmq_user { 'sensu':
    admin    => true,
    password => $::rabbitmq_sensu_password,
    notify   => Class['::sensu'],
  }

  rabbitmq_vhost { '/sensu':
    ensure => present,
    notify => Class['::sensu'],
  }

  rabbitmq_user_permissions { 'sensu@/sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
    notify               => Class['::sensu'],
  }

  sensu::handler { 'default':
    type     => 'set',
    handlers => ['logstash', 'slack'],
  }

  $pagerduty_api_key = hiera('pagerduty_api_key', undef)

  if $pagerduty_api_key != undef {
    sensu::handler { 'pagerduty':
      command => '/etc/sensu/community-plugins/handlers/notification/pagerduty.rb',
      config  => {
        api_key => $pagerduty_api_key,
      }
    }
  }

  $handler_dir = '/etc/sensu/handlers/'
  $notification_dir = "${handler_dir}notification/"

  file { $notification_dir:
    ensure => directory
  }

  $handler_file = "${notification_dir}logstash.rb"
  file { $handler_file:
    ensure  => 'present',
    source  => 'puppet:///modules/performanceplatform/sensu_logstash_handler.rb',
    mode    => '0755',
    require => File[$notification_dir]
  }

  sensu::handler { 'slack':
    command => '/etc/sensu/community-plugins/handlers/notification/slack.rb',
    config  => {
      token     => hiera('slack_token', ''),
      team_name => 'gds',
      channel   => "#${::pp_environment}-alerts",
      bot_name  => 'Alert bot 3000',
    },
  }

  sensu::handler { 'logstash':
    command => '/etc/sensu/handlers/notification/logstash.rb',
    config  => {
      type   => 'sensu',
      server => 'redis',
      port   => 6379,
      list   => 'sensu-checks',
    },
    require => File[$handler_file]
  }
}
