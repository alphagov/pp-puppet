require 'fpm/command'

desc "Build tarballs"
task :tar do
  version = ENV['BUILD_NUMBER']
  if version.nil?
    fail 'Please specify a version in the BUILD_NUMBER environment variable'
  end
  FileUtils.rm_rf 'target'
  FileUtils.mkdir_p 'target/etc/puppet/hieradata'
  FileUtils.mkdir_p 'build'
  FileUtils.cp_r 'manifests', 'target/etc/puppet'
  FileUtils.cp_r 'modules', 'target/etc/puppet'
  FileUtils.cp 'config/hiera/data/common.yaml', 'target/etc/puppet/hieradata'
  FileUtils.cp 'config/hiera/hiera_real.yaml', 'target/etc/puppet/hiera.yaml'
  args = "-s dir -t tar -a all -n pp-puppet -C target -v #{version} -p build/pp_puppet.tar.gz .".split
  FPM::Command.run(File.basename($0), args)
  FileUtils.rm_rf 'target'
end
