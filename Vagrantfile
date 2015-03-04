# -*- mode: ruby -*-
# vi: set ft=ruby :

# Node definitions
hosts = [
  { name: 'backend-app-1',          ip: '172.27.1.21' },
  { name: 'backend-app-2',          ip: '172.27.1.22' },
  # Note: development-1 also has the IP address 10.0.0.100 which services listen on.
  { name: 'development-1',          ip: '172.27.1.81'  },
  { name: 'frontend-app-1',         ip: '172.27.1.11' },
  { name: 'frontend-app-2',         ip: '172.27.1.12' },
  { name: 'jumpbox-1',              ip: '172.27.1.2' },
  { name: 'mongo-1',                ip: '172.27.1.31', extra_disk: true  },
  { name: 'mongo-2',                ip: '172.27.1.32', extra_disk: true  },
  { name: 'mongo-3',                ip: '172.27.1.33', extra_disk: true  },
  { name: 'monitoring-1',           ip: '172.27.1.41' },
  { name: 'logs-elasticsearch-1',   ip: '172.27.1.51', extra_disk: true },
  { name: 'logs-elasticsearch-2',   ip: '172.27.1.52', extra_disk: true },
  { name: 'logs-elasticsearch-3',   ip: '172.27.1.53', extra_disk: true },
  { name: 'postgresql-primary-1',   ip: '172.27.1.61' },
  { name: 'postgresql-secondary-1', ip: '172.27.1.65' },
  { name: 'backup-box-1',           ip: '172.27.1.71' },
]

# Images are built for specific versions of virtualbox guest additions for now.
# It has proven problematic to mix versions of virtualbox and guest additions
# in the past and therefore they are pinned by what is available in this map.
def create_box_details(virtualbox_version)
  box_name = "pp-ubuntu-12.04-virtualbox-#{virtualbox_version}"
  {
    name: box_name,
    url: "https://s3-eu-west-1.amazonaws.com/gds-boxes/#{box_name}.box",
    link: "http://download.virtualbox.org/virtualbox/#{virtualbox_version.split('r').first}"
  }
end

supported_box_versions = [
  "4.3.6r91406",
  "4.3.8r92456",
]

# Create a hash of virtualbox version to box details hash
$boxes_by_version = Hash[supported_box_versions.map {|virtualbox_version|
  [virtualbox_version, create_box_details(virtualbox_version)]
}]

def get_box(provider)
  provider ||= "virtualbox"
  case provider
  when "vmware"
    name  = "phusion/ubuntu-12.04-amd64"
    url   = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-12.04-amd64-vmwarefusion.box"
  else
    virtualbox_version = `vboxmanage --version`.strip
    box = $boxes_by_version[virtualbox_version]
    if box.nil?
      error = <<EOS
VirtualBox version #{virtualbox_version} is not supported. Falling back to latest VirtualBox box. See README.md.
Supported: #{$boxes_by_version.keys} --> #{$boxes_by_version.values.map {|item| item[:link]}}
EOS
$stderr.puts error unless @warned
    # Gem version to sort by version numbers, need to dup the string as it mutates
    # max by returns an array, which we convert back into a hash
    latest = $boxes_by_version.keys.max_by{|v| Gem::Version.new(v.dup)}
    box = $boxes_by_version[latest]
    @warned = true
    end

    name, url = box[:name], box[:url]
  end
  return name, url
end

def load_local_vagrant_file(name, config)
  # Load local overrides
  if File.exist? "#{name}-Vagrantfile.local"
    $stderr.puts "WARNING: Vagrantfile.local is deprecated! Please use Vagrantfile.localconfig instead."
    $stderr.puts ""
  end

  if File.exist? "#{name}-Vagrantfile.localconfig"
    instance_eval File.read("#{name}-Vagrantfile.localconfig"), "#{name}-Vagrantfile.localconfig"
  end

  config
end

if not Vagrant.respond_to?(:configure)
  puts $stderr.puts "ERROR: Please upgrade to Vagrant >= 1.1"
  exit 1
end

Vagrant.configure("2") do |config|
  if Vagrant.has_plugin? "vagrant-dns"
    config.dns.tld = "development.performance.service.gov.uk"
    config.dns.patterns = [/^.*development.performance.service.gov.uk$/]
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  hosts.each do |host|
    config.vm.define host[:name] do |c|
      box_name, box_url = get_box("virtualbox")
      c.vm.box = box_name
      c.vm.box_url = box_url

      c.vm.hostname = host[:name]
      c.vm.network :private_network, ip: host[:ip], netmask: '255.255.255.0'
      if host[:name] == 'development-1'
        c.vm.network :private_network, ip: '10.0.0.100', netmask: '255.255.255.0'
      end

      c.vm.provider :virtualbox do |vb, override|
        modifyvm_args = ['modifyvm', :id]
        # Mitigate boot hangs.
        modifyvm_args << "--rtcuseutc" << "on"
        # Isolate guests from host networking.
        modifyvm_args << "--natdnsproxy1" << "on"
        modifyvm_args << "--natdnshostresolver1" << "on"
        modifyvm_args << "--name" << host[:name]
        if ['development-1', 'monitoring-1'].include? host[:name]
          modifyvm_args << "--memory" << "1024"
        end
        vb.customize(modifyvm_args)
        if host[:extra_disk]
          file_to_disk =  "./tmp/#{host[:name]}-extra-disk.vdi"
          unless File.exists? file_to_disk
            vb.customize ['createhd', '--filename', file_to_disk, '--size', 512]
          end
          vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 1, '--type', 'hdd', '--medium', file_to_disk]
        end
      end

      c.vm.provider :vmware_fusion do |f, override|
        vf_box_name, vf_box_url = get_box("vmware")
        override.vm.box = vf_box_name
        override.vm.box_url = vf_box_url
        f.vmx["displayName"] = host[:name]
        if host[:extra_disk]
          vdiskmanager = '/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager'
          if File.exists?(vdiskmanager) && !File.exists?(file_to_disk)
            file_to_disk =  "./tmp/#{host[:name]}-extra-disk.vmdk"
            unless File.exists? file_to_disk
              `#{vdiskmanager} -c -s 512MB -a lsilogic -t 1 #{file_to_disk}`
            end
            f.vmx['scsi0:1.filename'] = File.dirname(__FILE__) + "/" + file_to_disk
            f.vmx['scsi0:1.present']  = 'TRUE'
            f.vmx['scsi0:1.redo']     = ''
          end
        end
      end

      c = load_local_vagrant_file(host[:name], c)
      c.vm.synced_folder "..", "/var/apps"
      if File.directory?('../pp-deployment')
        c.vm.synced_folder "../pp-deployment/environments/dev/hieradata", "/vagrant/hieradata/dev"
      end

      c.ssh.forward_agent = true
      c.vm.provision :shell, :inline => "/vagrant/tools/bootstrap-vagrant"
      c.vm.provision :shell, :inline => "/vagrant/tools/puppet-apply"
    end
  end
end
