define performanceplatform::checks::server (
    $domain
) {
    $fqdn = "${name}.${domain}"
    $graphite_fqdn = regsubst($fqdn, '\.', '_', 'G')

    performanceplatform::checks::graphite { "check_high_cpu_${name}":
      target   => "movingAverage(collectd.${graphite_fqdn}.cpu-0.cpu-idle,120)",
      warning  => '10',
      critical => '5',
      below    => true,
      interval => 60,
      handlers => ['default'],
    }

    performanceplatform::checks::graphite { "check_disk_io_${name}":
      target   => "movingMedian(sumSeries(collectd.${graphite_fqdn}.disk-sd?.disk_time.*),30)",
      warning  => '100',
      critical => '200',
      interval => 60,
      handlers => ['default'],
    }

    performanceplatform::checks::disk { "${fqdn}_root":
      fqdn => $fqdn,
      disk => "root",
    }

    performanceplatform::checks::graphite { "check_machine_is_down_${name}":
      target   => "transformNull(collectd.${graphite_fqdn}.uptime.uptime,0)",
      warning  => '0',
      critical => '0',
      below    => true,
      interval => 60,
      handlers => ['default'],
    }

    sensu::check { "check_ntp_${name}":
      command  => "/etc/sensu/community-plugins/plugins/system/check-ntp.rb -w 2 -c 3",
      interval => 3600,
      handlers => ['default']
    }
}
