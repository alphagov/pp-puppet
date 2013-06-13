import 'machines/*'
node default {
    $machine_class = regsubst($::hostname, '^(.*)-\d$', '\1')
    $underscored_machine_class = regsubst($machine_class, '-', '_')
    $node_class_name = "machines::${underscored_machine_class}"
    include $node_class_name
}
