if File.exist? 'vagrant/Vagrantfile.common'
    instance_eval File.read('vagrant/Vagrantfile.common'), 'Vagrantfile.common'
else
    abort("Cannot find vagrant/Vagrantfile.common")
end

"#{Vagrant::VERSION}" < "1.1.0" and Vagrant::Config.run do |config|
  nodes_from_json.each do |node_name, node_opts|
    config.vm.define node_name do |c|
      box_name, box_url = get_box("virtualbox")
      c.vm.box = box_name
      c.vm.box_url = box_url

      c.vm.host_name = node_name
      c.vm.network :hostonly, node_opts["ip"], :netmask => "255.000.000.000"


      if File.exist? 'vagrant/Vagrantfile.virtualbox'
          instance_eval File.read('vagrant/Vagrantfile.virtualbox'), 'Vagrantfile.virtualbox'
      else
          abort("Cannot find vagrant/Vagrantfile.virtualbox")
      end

      if File.exist? 'vagrant/Vagrantfile.provision'
          instance_eval File.read('vagrant/Vagrantfile.provision'), 'Vagrantfile.provision'
      else
          abort("Cannot find vagrant/Vagrantfile.provision")
      end
    end
  end
end

"#{Vagrant::VERSION}" >= "1.1.0" and Vagrant.configure("2") do |config|
  nodes_from_json.each do |node_name, node_opts|
    config.vm.define node_name do |c|
      box_name, box_url = get_box("virtualbox")
      c.vm.box = box_name
      c.vm.box_url = box_url

      c.vm.hostname = node_name
      c.vm.network :private_network, ip: node_opts["ip"], netmask: '255.000.000.000'

      c.vm.provider :virtualbox do |vb|
        if File.exist? 'vagrant/Vagrantfile.virtualbox'
          instance_eval File.read('vagrant/Vagrantfile.virtualbox'), 'Vagrantfile.virtualbox'
        else
          abort("Cannot find vagrant/Vagrantfile.virtualbox")
        end
      end


      c.vm.provider :vmware_fusion do |f|
        vf_box_name, vf_box_url = get_box("vmware")
        override.vm.box = vf_box_name
        override.vm.box_url = vf_box_url
        if node_opts.has_key?("memory")
          f.vmx["memsize"] = "256"
        else
          f.vmx["memsize"] = node_opts["memory"]
        end
        f.vmx["numvcpus"] = "1"
        f.vmx["displayName"] = node_name
      end

      if File.exist? 'vagrant/Vagrantfile.provision'
          instance_eval File.read('vagrant/Vagrantfile.provision'), 'Vagrantfile.provision'
      else
          abort("Cannot find vagrant/Vagrantfile.provision")
      end
    end
  end
end
