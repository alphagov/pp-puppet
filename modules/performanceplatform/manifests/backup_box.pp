# Class: performanceplatform::backup_box
#
#
class performanceplatform::backup_box {

    lvm::volume { 'data':
        ensure => 'present',
        vg     => 'backup',
        pv     => '/dev/sdb1',
        fstype => 'ext4',
    }

}
    # mapping aiming to conform to pattern lv-vg
