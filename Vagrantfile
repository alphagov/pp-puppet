if File.exist? 'vagrant/Vagrantfile.common'
    instance_eval File.read('vagrant/Vagrantfile.common'), 'Vagrantfile.common'
else
    abort("Cannot find vagrant/Vagrantfile.common")
end

"#{Vagrant::VERSION}" < "1.1.0" and Vagrant::Config.run do |config|
  if File.exist? 'vagrant/Vagrantfile.v1'
    instance_eval File.read('vagrant/Vagrantfile.v1'), 'Vagrantfile.v1'
  else
    abort("Cannot find vagrant/Vagrantfile.v1")
  end
end

"#{Vagrant::VERSION}" >= "1.1.0" and Vagrant.configure("2") do |config|
  if File.exist? 'vagrant/Vagrantfile.v2'
    instance_eval File.read('vagrant/Vagrantfile.v2'), 'Vagrantfile.v2'
  else
    abort("Cannot find vagrant/Vagrantfile.v2")
  end
end
