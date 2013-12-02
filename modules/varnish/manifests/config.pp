class varnish::config {
  include varnish::restart

  file { '/etc/default/varnish':
    ensure  => file,
    content => template('varnish/defaults.erb'),
    notify  => Class['varnish::restart'], # requires a full varnish restart to pick up changes
  }

  file { '/etc/default/varnishncsa':
    ensure  => file,
    source  => 'puppet:///modules/varnish/etc/default/varnishncsa',
  }

  case $::machine_role {
    'development': { $default_vcl_template = "varnish/default.vcl.development.erb" }
    default: { $default_vcl_template = "varnish/default.vcl.erb" }
  }

  file { '/etc/varnish/default.vcl':
    ensure  => file,
    content => template($default_vcl_template),
  }
}
