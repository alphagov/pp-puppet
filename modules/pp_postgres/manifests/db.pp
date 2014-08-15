define pp_postgres::db(
  $password
) {
  postgresql::server::db { $title:
    user     => $title,
    password => postgresql_password($title, $password),
  }

  postgresql::server::pg_hba_rule { $title:
    type        => 'host',
    database    => $title,
    user        => $title,
    auth_method => 'md5',
    address     => '172.27.1.1/24',
  }
}

