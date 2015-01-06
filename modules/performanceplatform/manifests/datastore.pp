#

class performanceplatform::datastore(
  $port = 3054,
  $healthcheck = '/_status',
  $app_module  = undef,
  $user = undef,
  $group = undef,
  $enabled = false,
  ) {
  

  if $enabled {  
    performanceplatform::app { 'performance-datastore':
      port                        => $port,
      app_module                  => $app_module,
      user                        => $user,
      group                       => $group,
      upstart_desc                => 'Datastore Job',
      upstart_exec                => './performance-datastore',
      proxy_append_forwarded_host => true,
      proxy_set_forwarded_host    => false,
      client_max_body_size        => '10m',
      statsd_prefix               => 'datastore',
      servername                  => 'datastore',
      extra_env                   => {
        'MONGO_URL'  => hiera('performanceplatform::datastore::mongo_url'),
        'CONFIG_API_URL' => hiera('performanceplatform::datastore::config_api_url'),
      },
    }
  }

}
