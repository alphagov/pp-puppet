class transactionsexplorer(
  $app_name,
  $server_name,
  $user,
  $group,
) {
  $app_path = "/opt/${app_name}"
  file { [$app_path, "${app_path}/releases", "${app_path}/artefacts"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }
  nginx::vhost { $app_name:
    servername => $server_name,
    vhostroot  => "${app_path}/current",
  }
}
