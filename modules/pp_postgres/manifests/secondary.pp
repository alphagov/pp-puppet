class pp_postgres::secondary {
  file { '/var/lib/postgresql/9.1/main/recovery.conf':
    ensure  => present,
    content => "standby_mode = 'on'\nprimary_conninfo = 'host=postgresql-primary-1'",
    owner   => "postgres",
    group   => "postgres",
  }

  postgresql::server::pg_hba_rule { 'stagecraft':
    type        => 'host',
    database    => 'stagecraft',
    user        => 'stagecraft',
    auth_method => 'md5',
    address     => '172.27.1.1/24',
  }
}
