class performanceplatform::opbeat_proxy(
  $servername,
  $organisation_id,
  $app_id,
  $token,
  $endpoint = '/exception',
  $ssl      = true,
) {

  nginx::resource::location { "${servername}-opbeat-proxy":
    vhost    => $servername,
    location => $endpoint,
    ssl      => $ssl,
    proxy    => "https://opbeat.com/api/v1/organizations/${organisation_id}/apps/${app_id}/errors/",
    location_cfg_append => {
      proxy_set_header => "Authorization \"Bearer ${token}\"",
    },
  }


}
