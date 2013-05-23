node default {
    if $::machine_class == '' {
        $warn_head = '$::machine_class is blank, not doing any initialization!'
        $warn_body = 'Consider sourcing `/etc/environment` or running with `sudo -i`'
        warning($warn_head)
        notify { "${warn_head} ${warn_body}": }
    } else {
        $underscored_machine_class = regsubst($::machine_class, '-', '_')
        $node_class_name = "machine_classes::${underscored_machine_class}"
        include $node_class_name
    }
}
