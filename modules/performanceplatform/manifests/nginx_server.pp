
class performanceplatform::nginx_server (
  $server_names_hash_bucket_size = 64,
) {

  class { 'nginx::server':
    server_names_hash_bucket_size => $server_names_hash_bucket_size,
    subscribe                      => Class['dnsmasq::service'],
  }

}
