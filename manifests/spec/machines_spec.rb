require 'rspec-puppet'
require 'hiera-puppet-helper'

HERE = File.expand_path('./')
RSpec.configure do |c|
      c.module_path = File.join(HERE, 'modules')
      c.manifest    = File.join(HERE, 'manifests', 'site.pp')
end

def class_list
  if ENV["classes"]
    ENV["classes"].split(",")
  else
    class_dir = File.expand_path("../../../manifests/machines", __FILE__)
    Dir.glob("#{class_dir}/*.pp").collect { |dir|
      dir.gsub(/^#{class_dir}\/(.+)\.pp$/, '\1')
    }
  end
end

describe "machines" do
  let(:hiera_config) do
    { :backends => ['yaml'],
      :hierarchy => [
        'environment',
        'common'],
      :yaml => {
        :datadir => File.expand_path(File.join('config', 'hiera', 'data')) }}
  end
  class_list.each do |machine_class|
    describe machine_class, :type => :host do
      let(:facts) {{
        :machine_class => machine_class,
        :osfamily      => "Debian",
        :operatingsystem => "Ubuntu",
        :lsbdistcodename => "Precise",
      }}

      it { should contain_class("machines::#{machine_class}") }
    end
  end
end
