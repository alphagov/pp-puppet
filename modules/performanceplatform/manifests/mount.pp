define performanceplatform::mount(
  $mountoptions,
  $disk,
) {

  if $::pp_environment == 'dev' {

    ensure_resource('file', $title, { 'ensure' => 'directory' })

  } else {

    ext4mount { $title:
      mountoptions => 'defaults',
      disk         => '/dev/mapper/data-elasticsearch',
    }

  }

}
