import 'machines/*'
$machine_class = regsubst($::hostname, '^(.*)-\d$', '\1')
$underscored_machine_class = regsubst($machine_class, '-', '_')
$node_class_name = "machines::${underscored_machine_class}"

$management_vhost = join(['management',hiera('domain_name')],'.')
$www_vhost        = join(['www',hiera('domain_name')],'.')
$admin_vhost      = join(['admin',hiera('domain_name')],'.')

hiera_include('includes_classes')

node default {
    include $node_class_name
}
