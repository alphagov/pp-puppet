require 'rspec/core/rake_task'
FileList['lib/tasks/*.rake'].each do |rake_file|
    import rake_file
end
task :test => [:puppetfile, :spec, :lint]
task :default => [:test]
