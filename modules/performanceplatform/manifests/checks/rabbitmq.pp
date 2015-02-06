class performanceplatform::checks::rabbitmq() {
  sensu::check { 'rabbitmq_is_down':
    command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'rabbitmq-server' -C 1 -W 1",
    interval => 60,
    handlers => ['default']
  }
}
