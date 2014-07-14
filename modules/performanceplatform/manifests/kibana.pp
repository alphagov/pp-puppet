class performanceplatform::kibana(
  $elasticsearch_url,
  $tarball_url,
  $extract_location = '/opt',
  $kibana_index = 'kibana-int',
) {

  $name_regex = '^http.+\/(.+)\.tar\.gz$'

  validate_re($tarball_url, $name_regex, 'Please use a valid kibana tarball source url')

  $tarball_name = regsubst($tarball_url, $name_regex, '\1')
  $app_root = "${extract_location}/${tarball_name}"

  archive { 'kibana3.0.0milestone4':
    ensure   => present,
    url      => $tarball_url,
    target   => $extract_location,
    checksum => false,
  }

  file { "${extract_location}/kibana-3.0.1":
    ensure  => absent,
    force   => true,
    purge   => true,
    recurse => true,
    backup  => false,
  }

  file { "${app_root}/config.js":
    ensure  => present,
    content => template('performanceplatform/kibana.config.js.erb'),
    require => Archive['kibana3.0.0milestone4'],
  }

  $ssl_path = hiera('ssl_path')
  $ssl_cert = hiera('environment_ssl_cert')
  $ssl_key = hiera('environment_ssl_key')

  nginx::resource::vhost { $::kibana_vhost:
    ssl         => true,
    ssl_cert    => "${ssl_path}/${ssl_cert}",
    ssl_key     => "${ssl_path}/${ssl_key}",
    www_root    => $app_root,
    access_log  => "${::kibana_vhost}.access.log.json json_event",
    require     => Archive['kibana3.0.0milestone4'],
  }

}
