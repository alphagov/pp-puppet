require 'spec_helper'

describe 'elasticsearch::install', :type => :class do
  let(:facts) { { :osfamily => "Debian"} }
  it "should fail when elasticsearch package version not specified" do
    expect {
      should contain_package('elasticsearch')
    }.to raise_error(Puppet::Error, /You must provide an elasticsearch version for package/)
  end

  context "with specified version" do
    let(:params) do
      { :version => '1.2.3' }
    end

    it do
      should contain_package('elasticsearch').with_ensure('1.2.3')
    end
  end
end
