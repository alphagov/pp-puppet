# Everything in this node definition depends on Hiera
# This defines the role of the node
$machine_class    = regsubst($::hostname, '^(.*)-\d$', '\1')

# Nginx Vhosts for later use
$management_vhost = join(['management',hiera('domain_name')],'.')
$www_vhost        = join(['www',hiera('domain_name')],'.')
$admin_vhost      = join(['admin',hiera('domain_name')],'.')

node default {

    # Environment specific variables
    $environment      = hiera('environment')

    # Create user accounts
    create_resources( 'account', hiera_hash('accounts') )

    # Install packages
    create_resources( 'package', hiera_hash('system_packages') )

    # Classes
    hiera_include('included_classes')
    $parameterised_classes = hiera_hash( 'parameterised_classes', {} )
    if !empty($parameterised_classes) {
        create_resources( 'class', $parameterised_classes )
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
        create_resources( 'backdrop::app', $backdrop_apps)
    }
}
