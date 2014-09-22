# == Class: performanceplatform::pp_nginx::rate_limit
#
# Nginx configs for "rate limiting":
#
# - Sets up sensible rate limit thresholds to mitigate against basic attacks
#
# === Parameters
#
class performanceplatform::pp_nginx::rate_limit {
  file { '/etc/nginx/conf.d/03-rate-limit.conf':
    ensure  => present,
    source  => 'puppet:///modules/performanceplatform/nginx/rate-limit.conf',
    require => Class['nginx::config'],
    notify  => Service['nginx'],
  }
}
