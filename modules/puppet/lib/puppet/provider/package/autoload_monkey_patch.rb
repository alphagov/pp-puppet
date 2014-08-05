require 'puppet/util/autoload'
require 'puppet/util/log'

Puppet::Util::Log.create({:level => :warning, :source => __FILE__, :message => "***** Monkey-patching out gem autoload feature *****"})

Puppet::Util::Autoload.class_eval do
  def self.gem_directories
    []
  end
end
