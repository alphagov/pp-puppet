require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  desc "Run Puppet specs with rspec-puppet"
  t.pattern = FileList[*get_modules.map { |x| "#{x}/spec/**/*_spec.rb" }]
  $stderr.puts '---> Running Puppet specs'
end
