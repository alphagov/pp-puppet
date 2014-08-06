# This node exists in production to serve all other environments. So that we:
#
#   - can maintain/promote consistent snapshots across all environments
#   - don't duplicate storage in each environment
#   - have something that we can point Vagrant and smaller environments to
#
class performanceplatform::apt (
  $root_dir
) {

  # Only mirror our current arch to save space. This means that some
  # `apt::source` resources will need to specify an `architecture` param to
  # select only "amd64" or "binary".
  class { 'aptly':
    package_ensure    => '0.6',
    config            => {
      'rootDir'       => $root_dir,
      'architectures' => [$::architecture],
    },
  }

  performanceplatform::mount { $root_dir:
    mountoptions => 'defaults',
    disk         => '/dev/mapper/data-apt',
  } -> Class['aptly']

  aptly::mirror {
    'aptly':
      location => 'http://repo.aptly.info',
      release  => 'squeeze',
      key      => '2A194991';
    'puppetlabs':
      location => 'http://apt.puppetlabs.com/',
      repos    => ['main', 'dependencies'],
      release  => 'stable',
      key      => '4BD6EC30';
    'govuk-ppa-precise':
      location => 'http://ppa.launchpad.net/gds/govuk/ubuntu',
      release  => 'precise',
      key      => '914D5813';
  }

  include nginx

  $ssl_path = hiera('ssl_path', '/etc/ssl')
  $ssl_cert = hiera('public_ssl_cert', 'certs/ssl-cert-snakeoil.pem')
  $ssl_key = hiera('public_ssl_key', 'private/ssl-cert-snakeoil.key')

  nginx::resource::vhost { 'apt.*':
    listen_port => 443,
    ssl         => true,
    ssl_cert    => "${ssl_path}/${ssl_cert}",
    ssl_key     => "${ssl_path}/${ssl_key}",
    autoindex   => on,
    www_root    => "${root_dir}/public",
  }

}
