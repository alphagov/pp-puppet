define performanceplatform::checks::disk (
  $fqdn,
  $disk,
) {
  $graphite_fqdn = regsubst($fqdn, '\.', '_', 'G')
  $graphite_disk = regsubst(regsubst($disk, '^/', ''), '/', '-', 'G')

  performanceplatform::checks::graphite { "check_low_disk_space_${graphite_fqdn}_${graphite_disk}":
    target   => "collectd.${graphite_fqdn}.df-${graphite_disk}.df_complex-free",
    warning  => '4000000000', # A little less than 4 gig
    critical => '1000000000',  # A little less than 1 gig
    below    => true,
    interval => 60,
    handlers => ['default'],
  }


  performanceplatform::checks::graphite { "check_low_disk_inodes_${graphite_fqdn}_${graphite_disk}":
    target   => "collectd.${graphite_fqdn}.df-${graphite_disk}.df_inodes-free",
    warning  => '500000',
    critical => '100000',
    below    => true,
    interval => 60,
    handlers => ['default'],
  }

  # hopefully will alert when the disk growth rate for the last hour is over
  # 10G, warn when over 5G - may need tuning if it becomes noisy
  performanceplatform::checks::graphite { "check_disk_growth_${graphite_fqdn}_${graphite_disk}":
    target   => "derivative(scaleToSeconds(collectd.${graphite_fqdn}.df-${graphite_disk}.df_complex-free,3600))",
    warning  => '5000000000', # 5 gig
    critical => '10000000000',  # 10 gig
    interval => 60,
    handlers => ['default'],
  }
}
