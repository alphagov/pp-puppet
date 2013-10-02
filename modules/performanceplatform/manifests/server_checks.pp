class performanceplatform::server_checks(
) {

    $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')

    performanceplatform::graphite_check { "check_high_cpu_${::hostname}":
      target   => "collectd.${graphite_fqdn}.cpu-0.cpu-idle",
      warning  => '20:',
      critical => '5:',
      interval => '10',
    }

    performanceplatform::graphite_check { "check_low_disk_space_${::hostname}":
      target   => "collectd.${graphite_fqdn}.df-root.df_complex-free",
      warning  => '1000000000:', # A little less than a gig
      critical => '500000000:',  # A little less than 500MB
      interval => '10',
    }

}
