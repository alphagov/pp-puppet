class performanceplatform::pp_rabbitmq {
  rabbitmq_user { 'transformer':
    admin    => false,
    password => $rabbitmq_transformer_password,
  }

  rabbitmq_vhost { '/transformations':
    ensure => present,
  }

  rabbitmq_user_permissions { 'transformer@/transformations':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
}
