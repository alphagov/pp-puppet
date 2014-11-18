class performanceplatform::big_screen (
  $app_path,
  $user,
  $group,
) {

  file { [$app_path, "${app_path}/releases", "${app_path}/shared",
          "${app_path}/shared/log", "${app_path}/shared/assets"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

}
