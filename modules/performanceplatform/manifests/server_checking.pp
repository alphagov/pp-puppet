class performanceplatform::server_checking(
  $boxes,
) {

  $domain = regsubst($::fqdn, '[\.]+\.(.*)', '\1')

  performanceplatform::server_checks{ $boxes:
    domain => $domain,
  }

}
