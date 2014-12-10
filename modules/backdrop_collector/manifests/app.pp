define backdrop_collector::app ($user, $group, $ensure) {
    $app_path = "/opt/${title}"
    $virtualenv_path = "${app_path}/shared/venv"
    $log_path = "/var/log/${title}"
    $config_path = "/etc/gds/${title}"

    if $ensure == 'present' {
        $ensure_directory = 'directory'
    }
    else {
        $ensure_directory = 'absent'
    }

    file { [$log_path, $config_path, $app_path, "${app_path}/releases", "${app_path}/shared", "${app_path}/shared/log"]:
        ensure  => $ensure_directory,
        owner   => $user,
        group   => $group,
        recurse => true,
        force   => true,
    }

    python::virtualenv { $virtualenv_path:
        ensure     => $ensure,
        version    => '2.7',
        systempkgs => false,
        owner      => $user,
        group      => $group,
        require    => File["${app_path}/shared"],
    }

    logstashforwarder::file { "collector-logs-for-${title}":
        paths  => [ "${app_path}/current/log/collector.log.json" ],
    }

    performanceplatform::remove_lumberjack { "collector-logs-for-${title}":
        ensure => absent,
        log_files => [ "${app_path}/current/log/collector.log.json" ]
    }

    logrotate::rule { "${title}-collector":
        path         => "${app_path}/shared/log/*.log ${app_path}/shared/log/*.log.json",
        rotate       => 10,
        rotate_every => 'day',
        missingok    => true,
        compress     => true,
        create       => true,
        create_mode  => '0640',
        create_owner => $user,
        create_group => $group,
    }

    sensu::check { "logstashforwarder_is_down_for_collector-logs-for-${title}":
        ensure  => absent,
        command  => "/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p 'lumberjack.*collector-logs-for-${title}' -C 1 -W 1",
        interval => 60,
        handlers => ['default'],
    }
}
