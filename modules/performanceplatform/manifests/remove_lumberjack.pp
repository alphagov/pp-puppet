define performanceplatform::remove_lumberjack (
  $log_files,
  $fields = { },
  $ensure = 'absent',
){

  if $ensure == 'absent' {
    $service_ensure = 'stopped'
  }
  else {
    $service_ensure = 'running'
  }

  $service_name = "${name}-logshipper"
  $upstart_file_path = "/etc/init/${name}-logshipper.conf"
  $config_file_path = "${performanceplatform::init_remove_lumberjack::config_dir}/${name}-logshipper.json"

  file { $upstart_file_path :
    ensure => $ensure,
  }

  file { $config_file_path :
    ensure => $ensure,
  }

}
