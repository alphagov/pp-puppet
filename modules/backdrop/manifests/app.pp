define backdrop::app (
    $port        = undef,
    $workers     = 4,
    $app_module  = undef,
    $user        = undef,
    $group       = undef,
) {
    include nginx::server
    include upstart

    $app_path = "/opt/${title}"
    $virtualenv_path = "${app_path}/shared/venv"
    $log_path = "/var/log/${title}"
    $config_path = "/etc/gds/${title}"

    file { [$log_path, $config_path, $app_path, "${app_path}/releases", "${app_path}/shared", "${app_path}/shared/log"]:
        ensure  => directory,
        owner   => $user,
        group   => $group,
        recurse => true,
    }
    nginx::vhost::proxy { "${title}-vhost":
        port          => 80,
        servername    => $title,
        ssl           => false,
        upstream_port => $port,

    }
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
    upstart::job { $title:
        description   => "Backdrop API for ${title}",
        respawn       => true,
        respawn_limit => '5 10',
        user          => $user,
        group         => $group,
        chdir         => "${app_path}/current",
        environment   => {
            "GOVUK_ENV"  => "production",
            "APP_NAME"   => $title,
            "APP_MODULE" => $app_module,
        },
        exec          => "${app_path}/run-procfile.sh"
    }
}
