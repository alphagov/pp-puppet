class performanceplatform::kibana(
  $elasticsearch_url,
  $version,
  $extract_location = '/opt',
  $kibana_index = 'kibana-int',
) {

  $kib_name = "kibana-${version}"
  $url = "https://download.elasticsearch.org/kibana/kibana/${kib_name}.tar.gz"

  $app_root = "${extract_location}/${kib_name}"

  archive { $kib_name:
    ensure   => present,
    url      => $url,
    target   => $extract_location,
    checksum => false,
  }

  file { "${app_root}/config.js":
    ensure  => present,
    content => template('performanceplatform/kibana.config.js.erb'),
    require => Archive[$kib_name],
  }

  $ssl_path = hiera('ssl_path')
  $ssl_cert = hiera('environment_ssl_cert')
  $ssl_key = hiera('environment_ssl_key')
  $ssl_dhparam = hiera('ssl_dhparam')

  nginx::resource::vhost { $::kibana_vhost:
    ssl         => true,
    ssl_cert    => "${ssl_path}/${ssl_cert}",
    ssl_key     => "${ssl_path}/${ssl_key}",
    ssl_dhparam => "${ssl_path}/${ssl_dhparam}",
    www_root    => $app_root,
    access_log  => "${::kibana_vhost}.access.log.json json_event",
    require     => Archive[$kib_name],
  }

}
