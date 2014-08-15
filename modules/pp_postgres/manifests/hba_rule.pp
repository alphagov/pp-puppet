# == Define: pp_postgres::hba_rule
#
# Wrapper around postgresql::server::pg_hba_rule that adds some
# Performance Platform specific defaults. Such as:
#  - type is always host, to avoid confusion
#  - database defaults to the user name
#  - address is always visible to the whole network
define pp_postgres::hba_rule (
  $database    = $title,
  $auth_method = 'md5',
) {
  postgresql::server::pg_hba_rule { $title:
    type        => 'host',
    database    => $database,
    user        => $title,
    auth_method => $auth_method,
    address     => '172.27.1.1/24',
  }
}
