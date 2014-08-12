require_relative "../../../../spec_helper"

describe "performanceplatform::checks::disk", :type => :define do
  let(:title) { 'not-used-for-anything' }

  let(:params) do
    {
      :fqdn => 'brilliant.example',
      :disk => '/root',
    }
  end

  it {
    should contain_performanceplatform__checks__graphite("check_low_disk_space_brilliant_example_root")
  }
  it {
    should contain_performanceplatform__checks__graphite("check_low_disk_inodes_brilliant_example_root")
  }
end
