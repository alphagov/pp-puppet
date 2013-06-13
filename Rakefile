def get_modules
      ['modules/*']
end

FileList['lib/tasks/*.rake'].each do |rake_file|
      import rake_file
end

desc "Run all specs"
task :spec

desc "Check for all Puppet syntax errors"
task :syntax => [:syntax_erb, :syntax_pp]

desc "Run puppet-lint against all modules"
task :lint

task :default => [:syntax_pp, :syntax_erb, :lint, :spec]
