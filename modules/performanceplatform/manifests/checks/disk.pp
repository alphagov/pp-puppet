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

}
