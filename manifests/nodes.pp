# Everything in this node definition depends on Hiera

# This defines the role of the node
$machine_role     = regsubst($::hostname, '^(.*)-\d$', '\1')

# Nginx Vhosts for later use
$domain_name        = hiera('domain_name')
$public_domain_name = hiera('public_domain_name', $domain_name)
$admin_vhost        = join(['admin',$public_domain_name],'.')
$deploy_vhost       = join(['deploy',$domain_name],'.')
$graphite_vhost     = join(['graphite',$domain_name],'.')
$logging_vhost      = join(['logging',$domain_name],'.')
$nagios_vhost       = join(['nagios',$domain_name],'.')
$www_vhost          = join(['www',$public_domain_name],'.')

# Classes
hiera_include('classes')

node default {

    # Environment specific variables
    $environment      = hiera('environment')

    # Create user accounts
    create_resources( 'account', hiera_hash('accounts') )

    # Install packages
    $system_packages = hiera_array( 'system_packages', [] )
    if !empty($system_packages) {
        package { $system_packages: ensure => installed }
    }

    # Firewall rules
    create_resources( 'ufw::allow', hiera_hash('ufw_rules') )

    # Create nginx proxies
    $vhost_proxies = hiera_hash( 'vhost_proxies', {} )
    if !empty($vhost_proxies) {
        create_resources( 'nginx::vhost::proxy', $vhost_proxies )
    }

    # Create extra nginx conf
    $nginx_conf = hiera_hash( 'nginx_conf', {} )
    if !empty($nginx_conf) {
        create_resources( 'nginx::conf', $nginx_conf )
    }

    # Install the apps
    $backdrop_apps = hiera_hash( 'backdrop_apps', {} )
    if !empty($backdrop_apps) {
        create_resources( 'backdrop::app', $backdrop_apps )
    }

    # Collect some metrics
    $collectd_plugins = hiera_array( 'collectd_plugins', [] )
    if !empty($collectd_plugins) {
        collectd::plugin { $collectd_plugins: }
    }
}
