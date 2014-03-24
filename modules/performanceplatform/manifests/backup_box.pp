# Class: performanceplatform::backup_box
#
#
class performanceplatform::backup_box(
    $data_dir,
    $disk_mount,
) {


    lvm::volume { 'data':
        ensure => 'present',
        vg     => 'backup',
        pv     => '/dev/sdb1',
        fstype => 'ext4',
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
    # mapping aiming to conform to pattern lv-vg
