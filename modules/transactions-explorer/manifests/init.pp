class transactions-explorer(
  $servername,
  $user,
  $group,
) {
  $app_path = "/opt/${title}"
  file { ["${app_path}", "${app_path}/releases", "${app_path}/artefacts"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }
  nginx::vhost { "$title":
    servername => $servername,
    vhostroot  => "${app_path}/current",
  }
}