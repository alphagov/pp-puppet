# == Class: performanceplatform::assets
#
# This class provides an nginx vhost that serves assets from
# a dedicated assets subdomain. You should be able to set far
# future cache headers on your assets here.
class performanceplatform::assets (
) {

  $ssl_path = hiera('ssl_path')
  $ssl_cert = hiera('public_ssl_cert')
  $ssl_key = hiera('public_ssl_key')
  $ssl_dhparam = hiera('ssl_dhparam')

  nginx::resource::vhost { $::assets_internal_vhost:
    ssl                 => true,
    ssl_cert            => "${ssl_path}/${ssl_cert}",
    ssl_key             => "${ssl_path}/${ssl_key}",
    ssl_dhparam         => "${ssl_path}/${ssl_dhparam}",
    access_log          => "${::assets_internal_vhost}.access.log.json json_event",
    location_custom_cfg => {
      'return' => '204',
    },
  }

  nginx::resource::location { 'spotlight-assets':
    location             => '/spotlight/',
    rewrite_rules        => [
      '^/spotlight(.*)$ $1 break'
    ],
    vhost                => $::assets_internal_vhost,
    www_root             => '/opt/spotlight/shared/assets',
    location_cfg_prepend => {
      'expires' => '30d',
    },
  }

  nginx::resource::location { 'stagecraft-assets':
    location             => '/stagecraft/',
    rewrite_rules        => [
      '^/stagecraft(.*)$ $1 break'
    ],
    vhost                => $::assets_internal_vhost,
    www_root             => '/opt/stagecraft/current/assets',
    location_cfg_prepend => {
      'expires' => '1h',
    },
  }

}
