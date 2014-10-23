# == Class elasticsearch::params
#
# This class is meant to be called from elasticsearch
# It sets variables according to platform
#
class elasticsearch::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'elasticsearch'
      $service_name = 'elasticsearch'
    }
    'RedHat', 'Amazon': {
      $package_name = 'elasticsearch'
      $service_name = 'elasticsearch'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
