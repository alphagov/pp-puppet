def get_modules
      ['modules/*']
end

FileList['lib/tasks/*.rake'].each do |rake_file|
      import rake_file
end

desc "Run all specs"
task :spec

desc "Run puppet-lint against all modules"
task :lint

task :test => [:syntax, :lint, :spec]

task :default => [:syntax, :lint, :spec]
