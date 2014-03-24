require_relative '../../../../spec_helper'

describe 'performanceplatform::backup_box', :type => :class do

    let (:params) {{
        'data_dir'      => '/mnt/data/backup',
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

    it { should contain_performanceplatform__mount('/mnt/data/backup') }

end
