require_relative '../../../../spec_helper'

describe 'performanceplatform::backup_box', :type => :class do
    it { should contain_lvm__volume('data').with(
        :vg     => 'backup',
        :pv     => '/dev/sdb1',
        :fstype => 'ext4',
    )}
end


# describe 'govuk::lvm', :type => :define do
#   let(:title) { 'purple' }

#   context 'with no params' do
#     it { expect { should contain_lvm__volume('purple') }.to raise_error(Puppet::Error, /Must pass pv/) }
#   end
