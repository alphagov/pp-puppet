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

  archive { 'kibana':
    ensure   => present,
    url      => $tarball_url,
    target   => $extract_location,
    checksum => false,
  }

  file { "${app_root}/config.js":
    ensure  => present,
    content => template('performanceplatform/kibana.config.js.erb'),
    require => Archive['kibana'],
  }

  nginx::vhost { 'kibana-vhost':
    servername  => "${::kibana_vhost}",
    ssl         => true,
    vhostroot   => $app_root,
    access_logs => {
      '{name}.access.log.json' => 'json_event',
    },
    require     => Archive['kibana'],
  }

}
