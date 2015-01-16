define performanceplatform::checks::disk (
  $fqdn                 = undef,
  $disk                 = undef,
  $disk_space_warning   = '4000000000', # A little less than 4 gig
  $disk_space_critical  = '1000000000', # A little less than 1 gig
  $inodes_warning       = '500000',
  $inodes_critical      = '100000',
  $disk_growth_warning  = '5000000000', # 5 gig
  $disk_growth_critical = '10000000000', # 10 gig
) {
  $graphite_fqdn = regsubst($fqdn, '\.', '_', 'G')
  $graphite_disk = regsubst(regsubst($disk, '^/', ''), '/', '-', 'G')

  performanceplatform::checks::graphite { "check_low_disk_space_${graphite_fqdn}_${graphite_disk}":
    target   => "collectd.${graphite_fqdn}.df-${graphite_disk}.df_complex-free",
    warning  => $disk_space_warning,
    critical => $disk_space_critical,
    below    => true,
    interval => 60,
    handlers => ['default'],
  }


  performanceplatform::checks::graphite { "check_low_disk_inodes_${graphite_fqdn}_${graphite_disk}":
    target   => "collectd.${graphite_fqdn}.df-${graphite_disk}.df_inodes-free",
    warning  => $inodes_warning,
    critical => $inodes_critical,
    below    => true,
    interval => 60,
    handlers => ['default'],
  }

  # hopefully will alert when the disk growth rate for the last hour is over
  # 10G, warn when over 5G - may need tuning if it becomes noisy
  performanceplatform::checks::graphite { "check_disk_growth_${graphite_fqdn}_${graphite_disk}":
    ensure   => absent,
    target   => "derivative(scaleToSeconds(collectd.${graphite_fqdn}.df-${graphite_disk}.df_complex-free,3600))",
    warning  => $disk_growth_warning,
    critical => $disk_growth_critical,
    interval => 60,
    handlers => ['default'],
  }
}
