# Class: performanceplatform::backup_box
#
#
class performanceplatform::backup_box(
    $data_dir,
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

    performanceplatform::mount { $data_dir:
        mountoptions => 'defaults',
        disk         => $disk_mount,
        require      => File['/mnt/data'],
    }

}
