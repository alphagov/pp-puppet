class performanceplatform::checks::servers (
  $boxes,
) {

  $domain = regsubst($::fqdn, '[^\.]+\.(.*)', '\1', 'G')

  performanceplatform::checks::server { $boxes:
    domain => $domain,
  }

}
