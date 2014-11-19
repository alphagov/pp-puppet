class performanceplatform::pp_rabbitmq ($transformer_password) {
  rabbitmq_user { 'transformer':
    admin    => false,
    password => $transformer_password,
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
