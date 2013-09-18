class backdrop_collector::app (
    $user        = undef,
    $group       = undef,
) {
    $app_path = "/opt/${title}"
    $virtualenv_path = "${app_path}/shared/venv"
    $log_path = "/var/log/${title}"
    $config_path = "/etc/gds/${title}"

    file { ["$log_path", "$config_path", "$app_path", "$app_path/releases", "$app_path/shared", "$app_path/shared/log"]:
        ensure  => directory,
        owner   => $user,
        group   => $group,
        recurse => true,
    }

    python::virtualenv { "$virtualenv_path":
        ensure     => present,
        version    => '2.7',
        systempkgs => false,
        owner      => $user,
        group      => $group,
        require    => File["$app_path/shared"],
    }
}
