define backdrop::app (
    $port        = undef,
    $workers     = 4,
    $app_module  = undef,
    $user        = undef,
    $group       = undef,
) {
    $app_path        = "/opt/${title}"
    $config_path     = "/etc/gds/${title}"
    $virtualenv_path = "${app_path}/shared/venv"

    performanceplatform::app { $title:
        port         => $port,
        workers      => $workers,
        app_module   => $app_module,
        user         => $user,
        group        => $group,
        app_path     => $app_path,
        config_path  => $config_path,
        upstart_desc => "Backdrop API for ${title}",
        upstart_exec => "${app_path}/run-procfile.sh",
    }

    # Backdrop specific stuff
    python::virtualenv { $virtualenv_path:
        ensure     => present,
        version    => '2.7',
        systempkgs => false,
        owner      => $user,
        group      => $group,
        require    => File["${app_path}/shared"],
    }
    file { "${config_path}/gunicorn":
        ensure  => present,
        owner   => $user,
        group   => $group,
        content => template('backdrop/gunicorn.erb')
    }
    file { "${app_path}/run-procfile.sh":
        ensure  => present,
        owner   => $user,
        group   => $group,
        mode    => 'a+x',
        source  => 'puppet:///modules/backdrop/run-procfile.sh'
    }
}
