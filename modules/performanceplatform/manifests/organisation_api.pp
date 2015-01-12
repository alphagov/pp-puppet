class performanceplatform::organisation_api (
  $port = 3060,
) {
  
  performanceplatform::app { 'organisation-api':
    port                        => $port,
    user                        => 'deploy',
    group                       => 'deploy',
    upstart_exec                => './organisation-api',
    proxy_append_forwarded_host => true,
  }

}
