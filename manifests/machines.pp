$machine_class = regsubst($::hostname, '^(.*)-\d$', '\1')

$management_vhost = join(['management',hiera('domain_name')],'.')
$www_vhost        = join(['www',hiera('domain_name')],'.')
$admin_vhost      = join(['admin',hiera('domain_name')],'.')

hiera_include('included_classes')

node default {
    #Store the list of hosts for use later
    $hosts = hiera('hosts')
    $environment = hiera('environment')
    # Manage /etc/hosts
    create_resources( 'host', hiera_hash('hosts') )
    # Create user accounts
    create_resources( 'account', hiera_hash('accounts') )
    # Install packages
    create_resources( 'package', hiera_hash('system_packages') )
    # Parameterized classes
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
