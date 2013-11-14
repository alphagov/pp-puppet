define performanceplatform::mount(
  $mountoptions,
  $disk,
) {

  if hiera('environment') == 'development' {

    ensure_resource('file', $title, { 'ensure' => 'directory' })

  } else {

    ext4mount { $title:
      mountoptions => 'defaults',
      disk         => heira('performanceplatform::elasticsearch:disk_mount'),
    }

  }

}
