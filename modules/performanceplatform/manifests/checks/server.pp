define performanceplatform::checks::server (
    $domain
) {
    $fqdn = "${name}.${domain}"
    $graphite_fqdn = regsubst($fqdn, '\.', '_', 'G')

    performanceplatform::checks::graphite { "check_high_cpu_${name}":
      target   => "movingAverage(collectd.${graphite_fqdn}.cpu-0.cpu-idle,120)",
      warning  => '20:',
      critical => '5:',
      interval => 60,
      handlers => ['default'],
    }

    performanceplatform::checks::graphite { "check_low_disk_space_${name}":
      target   => "collectd.${graphite_fqdn}.df-root.df_complex-free",
      warning  => '4000000000:', # A little less than 4 gig
      critical => '1000000000:',  # A little less than 1 gig
      interval => 60,
      handlers => ['default'],
    }

    performanceplatform::checks::graphite { "check_machine_is_down_${name}":
      target   => "transformNull(collectd.${graphite_fqdn}.uptime.uptime,0)",
      warning  => '0:',
      critical => '0:',
      interval => 60,
      handlers => ['default'],
    }
}
