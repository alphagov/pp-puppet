define performanceplatform::server_checks(
    $domain
) {
    $fqdn = "${name}.${domain}"
    $graphite_fqdn = regsubst($fqdn, '\.', '_', 'G')

    performanceplatform::graphite_check { "check_high_cpu_${name}":
      target   => "collectd.${graphite_fqdn}.cpu-0.cpu-idle",
      warning  => '20:',
      critical => '5:',
      interval => '10',
    }

    performanceplatform::graphite_check { "check_low_disk_space_${name}":
      target   => "collectd.${graphite_fqdn}.df-root.df_complex-free",
      warning  => '4000000000:', # A little less than 4 gig
      critical => '1000000000:',  # A little less than 1 gig
      interval => '10',
      handlers => 'pagerduty',
    }

    performanceplatform::graphite_check { "check_machine_is_down_${name}":
      target   => "transformNull(collectd.${graphite_fqdn}.uptime.uptime)",
      warning  => '0:',
      critical => '0:',
      interval => '1',
      handlers => 'pagerduty',
    }
}
