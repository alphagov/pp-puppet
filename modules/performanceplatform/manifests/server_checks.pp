class performanceplatform::server_checks(
) {

    $graphite_fqdn = regsubst($::fqdn, '\.', '_')

    performanceplatform::graphite_check { "check_high_cpu_${::hostname}":
      target   => "collectd.${graphite_fqdn}.cpu-0.cpu-idle",
      warning  => '20:',
      critical => '5:',
      interval => '10',
    }

}
