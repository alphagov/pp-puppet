require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'

HERE = File.expand_path(File.dirname(__FILE__))
fixture_path = File.join(HERE, 'spec', 'fixtures')

class Puppet::Resource
  # If you test a class which has a default parameter, but don't
  # explicitly pass the parameter in, Puppet explodes because it tries
  # to automatically inject parameter values from hiera and gets
  # confused due to hiera-puppet-helper's antics. This monkey patch
  # disables automatic parameter injection to stop that happening.
  def lookup_external_default_for(param, scope)
    nil
  end
end

RSpec.configure do |config|
  config.module_path  = "./modules:./vendor/modules"
  config.manifest     = File.join(fixture_path, 'manifests', 'site.pp')
end
