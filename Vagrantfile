# -*- mode: ruby -*-
# vi: set ft=ruby :

# Node definitions
hosts = [
  { name: 'backend-app-1',         ip: '172.27.1.21' },
  { name: 'backend-app-2',         ip: '172.27.1.22' },
  { name: 'development-1',         ip: '172.27.1.5'  },
  { name: 'frontend-app-1',        ip: '172.27.1.11' },
  { name: 'frontend-app-2',        ip: '172.27.1.12' },
  { name: 'jumpbox-1',             ip: '172.27.1.2' },
  { name: 'mongo-1',               ip: '172.27.1.31' },
  { name: 'mongo-2',               ip: '172.27.1.32' },
  { name: 'mongo-3',               ip: '172.27.1.33' },
  { name: 'monitoring-1',          ip: '172.27.1.41' },
  { name: 'logs-elasticsearch-1',  ip: '172.27.1.51' },
  { name: 'logs-elasticsearch-2',  ip: '172.27.1.52' },
  { name: 'postgresql-primary-1',  ip: '172.27.1.61' },
  { name: 'backup-box-1',          ip: '172.27.1.71' },
]

def get_box(provider)
  provider    ||= "virtualbox"
  case provider
  when "vmware"
    name  = "puppetlabs-ubuntu-server-12042-x64-vf503-nocm"
    url   = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-svr-12042-x64-vf503-nocm.box"
  else
    name  = "pp-ubuntu-12.04-virtualbox-4.3.6r91406"
    url   = "https://s3-eu-west-1.amazonaws.com/gds-boxes/pp-ubuntu-12.04-virtualbox-4.3.6r91406.box"
  end
  return name, url
end

if not Vagrant.respond_to?(:configure)
  puts $stderr.puts "ERROR: Please upgrade to Vagrant >= 1.1"
  exit 1
end

Vagrant.configure("2") do |config|
  hosts.each do |host|
    config.vm.define host[:name] do |c|
      box_name, box_url = get_box("virtualbox")
      c.vm.box = box_name
      c.vm.box_url = box_url

      c.vm.hostname = host[:name]
      c.vm.network :private_network, ip: host[:ip], netmask: '255.255.255.0'

      c.vm.provider :virtualbox do |vb, override|
        modifyvm_args = ['modifyvm', :id]
        # Mitigate boot hangs.
        modifyvm_args << "--rtcuseutc" << "on"
        # Isolate guests from host networking.
        modifyvm_args << "--natdnsproxy1" << "on"
        modifyvm_args << "--natdnshostresolver1" << "on"
        modifyvm_args << "--name" << host[:name]
        if host[:name] == 'monitoring-1'
          modifyvm_args << "--memory" << "1024"
        end
        vb.customize(modifyvm_args)
      end

      c.vm.provider :vmware_fusion do |f, override|
        vf_box_name, vf_box_url = get_box("vmware")
        override.vm.box = vf_box_name
        override.vm.box_url = vf_box_url
        f.vmx["memsize"] = "256"
        f.vmx["numvcpus"] = "1"
        f.vmx["displayName"] = host[:name]
      end

      c.vm.synced_folder "..", "/var/apps"
      if host[:name] == 'development-1' and File.directory?('../pp-deployment')
        c.vm.synced_folder "../pp-deployment/environments/dev", "/vagrant/hieradata/dev"
      end

      c.ssh.forward_agent = true
      c.vm.provision :shell, :path => "tools/bootstrap-vagrant"
    end
  end
end
