define pp_postgres::db(
  $password
) {
  postgresql::server::db { $title:
    user     => $title,
    password => postgresql_password($title, $password),
  }

  pp_postgres::hba_rule { $title:
  }
}

