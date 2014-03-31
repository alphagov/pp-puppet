require_relative '../../../../spec_helper'

describe 'performanceplatform::backup_box', :type => :class do

    let (:params) {{
        'backup_dir'    => '/mnt/data/backup',
        'disk_mount'    => '/dev/mapper/data-backup',
    }}

    it { should contain_lvm__volume('data').with(
        :ensure => 'present',
        :vg     => 'backup',
        :pv     => '/dev/sdb1',
        :fstype => 'ext4',
    )}

    it { should contain_file('/mnt/data').with_ensure(
        "directory"
    )}

    it { should contain_performanceplatform__mount('/mnt/data/backup').with(
        :disk   => '/dev/mapper/data-backup',
    )}

    it { should contain_file('/mnt/data/backup/postgresql').with(
        :ensure   => "directory",
        :owner    => "deploy",
    )}

    it { should contain_file('/mnt/data/backup/mongodb').with(
        :ensure   => "directory",
        :owner    => "deploy",
    )}

end
