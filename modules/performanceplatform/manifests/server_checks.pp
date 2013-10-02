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
      warning  => '4000000000:', # A little less than 4 gig
      critical => '1000000000:',  # A little less than 1 gig
      interval => '10',
    }

}
