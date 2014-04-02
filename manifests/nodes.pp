# Everything in this node definition depends on Hiera

# This defines the role of the node
if empty($machine_role) {
    $machine_role   = regsubst($::hostname, '^(.*)-\d$', '\1')
}

# Nginx vhosts for later use
$domain_name         = hiera('domain_name')
$public_domain_name  = hiera('public_domain_name', $domain_name)
# Public vhosts
$www_vhost           = join(['www',$public_domain_name],'.')
$admin_vhost         = join(['admin',$public_domain_name],'.')
$assets_vhost        = join(['assets',$public_domain_name],'.')
$stagecraft_vhost    = join(['stagecraft',$domain_name],'.')
# Private vhosts
$assets_internal_vhost = 'assets.frontend'
$deploy_vhost        = join(['deploy',$domain_name],'.')
$elasticsearch_vhost = join(['elasticsearch', $domain_name], '.')
$kibana_vhost        = join(['kibana', $domain_name], '.')
$graphite_vhost      = join(['graphite',$domain_name],'.')
$logstash_vhost      = join(['logstash',$domain_name],'.')
$logging_vhost       = join(['logging',$domain_name],'.')
$alerts_vhost        = join(['alerts',$domain_name],'.')
$spotlight_vhost = join(['spotlight',$domain_name],'.')
$screenshot_as_a_service_vhost = join(['screenshot', $public_domain_name], '.')

$rabbitmq_sensu_password = hiera('rabbitmq_sensu_password')

$basic_auth_username = hiera('basic_auth_username')
$basic_auth_password = hiera('basic_auth_password')
$basic_auth_password_hashed = hiera('basic_auth_password_hashed')

$pp_environment = hiera('pp_environment')

# Classes
hiera_include('classes')

node default {
  # Create user accounts
  create_resources( 'account', hiera_hash('accounts') )

  # Install packages
  $system_packages = hiera_array( 'system_packages', [] )
  if !empty($system_packages) {
    package { $system_packages: ensure => installed }
  }

  $python_packages = hiera_array( 'python_packages', [] )
  if !empty($python_packages) {
    package { $python_packages:
      ensure   => installed,
      provider => 'pip',
      require  => Package['python-pip'],
    }
  }

  $ruby_packages = hiera_array( 'ruby_packages', [] )
  if !empty($ruby_packages) {
    package { 'ruby1.9.1-dev':
      ensure => installed,
    }

    package { $ruby_packages:
      ensure   => installed,
      provider => 'gem',
      require  => Package['ruby1.9.1-dev'],
    }
  }

  # Firewall rules
  create_resources( 'ufw::allow', hiera_hash('ufw_rules') )

  # Create nginx proxies
  $vhost_proxies = hiera_hash( 'vhost_proxies', {} )
  if !empty($vhost_proxies) {
    create_resources( 'performanceplatform::proxy_vhost', $vhost_proxies )
  }

  # Create extra nginx conf
  $nginx_conf = hiera_hash( 'nginx_conf', {} )
  if !empty($nginx_conf) {
    create_resources( 'nginx::conf', $nginx_conf )
  }

  # Install the Gunicorn apps
  $gunicorn_apps = hiera_hash( 'gunicorn_apps', {} )
  if !empty($gunicorn_apps) {
    create_resources( 'performanceplatform::gunicorn_app', $gunicorn_apps )
  }

  # Collect some metrics
  $collectd_plugins = hiera_array( 'collectd_plugins', [] )
  if !empty($collectd_plugins) {
    collectd::plugin { $collectd_plugins: }
  }

  $lumberjack_instances = hiera_hash( 'lumberjack_instances', {} )
  if !empty($lumberjack_instances) {
    create_resources( 'lumberjack::logshipper', $lumberjack_instances )
  }
}
