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

    file { $backup_dir + '/postgresql':
        ensure => directory,
        owner  => 'deploy',
        require => [Performanceplatform::Mount[$backup_dir]],
    }

    file { $backup_dir + '/mongodb':
        ensure => directory,
        owner  => 'deploy',
        require => [Performanceplatform::Mount[$backup_dir]],
    }
}
