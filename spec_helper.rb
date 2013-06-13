require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'

HERE = File.expand_path(File.dirname(__FILE__))
fixture_path = File.join(HERE, 'spec', 'fixtures')

RSpec.configure do |config|
  config.module_path  = "./modules:./vendor/modules"
  config.manifest     = File.join(fixture_path, 'manifests', 'site.pp')
end

shared_context "hieradata" do
  # this mirrors ./hiera.yaml
  let(:hiera_config) do
    { :backends  => ['yaml'],
      :hierarchy => ['%{::hostname}','%{::server_role}','%{::hmrc_platform}'],
      :yaml      => {:datadir => File.join(HERE, 'hieradata')},
      :rspec => respond_to?(:hiera_data) ? hiera_data : {}•
    }
  end
end
