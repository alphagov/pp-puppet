require 'fpm/command'

desc "Build .deb package"
task :deb do
  version = ENV['BUILD_NUMBER']
  if version.nil?
    fail 'Please specify a version in the BUILD_NUMBER environment variable'
  end
  FileUtils.rm_rf 'target'
  FileUtils.mkdir_p 'target/etc/puppet'
  FileUtils.cp_r 'manifests', 'target/etc/puppet'
  FileUtils.cp_r 'modules', 'target/etc/puppet'
  FileUtils.cp_r 'config/hiera/data', 'target/etc/puppet/hieradata'
  FileUtils.cp 'src/hiera.yaml', 'target/etc/puppet'
  args = "-s dir -t deb -a all -n pp-puppet -C target -v #{version} -p pp_puppet_#{version}.deb .".split
  FPM::Command.run(File.basename($0), args)
end
