# Everything in this node definition depends on Hiera
# This defines the role of the node
$machine_role     = regsubst($::hostname, '^(.*)-\d$', '\1')

# Nginx Vhosts for later use
$admin_vhost      = join(['admin',hiera('domain_name')],'.')
$deploy_vhost     = join(['deploy',hiera('domain_name')],'.')
$graphite_vhost   = join(['graphite',hiera('domain_name')],'.')
$logging_vhost    = join(['logging',hiera('domain_name')],'.')
$nagios_vhost     = join(['nagios',hiera('domain_name')],'.')
$www_vhost        = join(['www',hiera('domain_name')],'.')

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
