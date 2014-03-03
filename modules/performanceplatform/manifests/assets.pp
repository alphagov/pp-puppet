# == Class: performanceplatform::assets
#
# This class provides an nginx vhost that serves assets from
# a dedicated assets subdomain. You should be able to set far
# future cache headers on your assets here.
class performanceplatform::assets (
) {

  nginx::vhost { 'assets-vhost':
    servername => $::assets_internal_vhost,
    ssl        => true,
    magic      => template('performanceplatform/assets-vhost.erb'),
  }

}
