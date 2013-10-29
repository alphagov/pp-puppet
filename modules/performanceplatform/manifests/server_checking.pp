class performanceplatform::server_checking(
  $boxes,
) {

  $domain = rebsubst($::fqdn, '[\.]+\.(.*)', '\1')

  performanceplatform::server_checks{ $boxes:
    domain => $domain,
  }

}
