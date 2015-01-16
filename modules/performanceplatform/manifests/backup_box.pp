# Class: performanceplatform::backup_box
#
#
class performanceplatform::backup_box(
    $backup_dir,  # directory inside /mnt/data
    $disk_mount,
) {

    if $::pp_environment == 'dev' {

        ensure_resource('file', '/dev/sdb1', { 'ensure' => 'directory' })

    } else {

        lvm::volume { 'data':
            ensure => 'present',
            vg     => 'backup',
            pv     => '/dev/sdb1',
            fstype => 'ext4',
        }

    }

    file { '/mnt/data':
        ensure => directory,
    }

    performanceplatform::mount { $backup_dir:
        mountoptions => 'defaults',
        disk         => $disk_mount,
        require      => File['/mnt/data'],
    }

    performanceplatform::checks::disk { "${::fqdn}_${backup_dir}":
        fqdn => $::fqdn,
        disk => $backup_dir,
    }

    performanceplatform::checks::disk { "${::fqdn}_/boot":
        fqdn                 => $::fqdn,
        disk                 => '/boot',
        disk_space_warning   => '300000000', # 300 MB (megabytes)
        disk_space_critical  => '400000000',  # 400 MB (megabytes) out of 474 total
        inodes_warning       => '80000',
        inodes_critical      => '100000', #out of a total 124928
        disk_growth_warning  => '50000000', # 50 MB (megabytes)
        disk_growth_critical => '100000000',  # 100 MB (megabytes)
    }

    file { "${backup_dir}/postgresql":
        ensure  => directory,
        owner   => 'deploy',
        require => [Performanceplatform::Mount[$backup_dir]],
    }

    file { "${backup_dir}/mongodb":
        ensure  => directory,
        owner   => 'deploy',
        require => [Performanceplatform::Mount[$backup_dir]],
    }
}
