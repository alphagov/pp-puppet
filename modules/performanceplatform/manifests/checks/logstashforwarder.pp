class performanceplatform::checks::logstashforwarder(
) {
  sensu::check { 'logstashforwarder_is_down':
      command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'logstash-forwarder' -C 1 -W 1",
      interval => 60,
      handlers => ['default']
  }
}
