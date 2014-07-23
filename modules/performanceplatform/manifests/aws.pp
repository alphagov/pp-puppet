class performanceplatform::aws($amazon_config_dir, $amazon_config_file) {
    file { $amazon_config_dir:
        ensure   => directory,
        path     => $amazon_config_dir,
        owner    => $user,
        group    => $group,
    }

    file { $amazon_config_file:
        ensure   => present,
        path     => $amazon_config_file,
        require  => File[$amazon_config_dir],
        content  => template('performanceplatform/aws-config.erb'),
    }
}
