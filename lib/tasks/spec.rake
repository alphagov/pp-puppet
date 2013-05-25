require 'rspec-puppet'
namespace :spec do
  desc "Run machines class specs"
  RSpec::Core::RakeTask.new(:machines) do |t|
          t.pattern = 'manifests/spec/machines_spec.rb'
          t.ruby_opts = '-W0'
          t.rspec_opts = '--color -fd'
  end
end
desc "Run rspec"
task :spec => 'spec:machines'
