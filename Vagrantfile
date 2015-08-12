# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Defaults for config options defined in CONFIG
$update_channel = "alpha"
$image_version = "current"
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 1

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % $update_channel
  if $image_version != "current"
      config.vm.box_version = $image_version
  end
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define vm_name = "pxe-server" do |config|
    config.vm.hostname = vm_name

    config.vm.provider :virtualbox do |vb|
      vb.gui = $vm_gui
      vb.memory = $vm_memory
      vb.cpus = $vm_cpus
    end

    ip = "10.10.10.90"
    config.vm.network :public_network, ip: ip

    # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
    #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    shared_folders = {
	'./config/' => '/mnt/pxe-server/config/',
	'./data/' => '/mnt/pxe-server/data/',
	'./units/' => '/home/core/units/'
    }

    shared_folders.each_with_index do |(host_folder, guest_folder), index|
      config.vm.synced_folder host_folder.to_s, guest_folder.to_s, type: "smb"
    end

    if File.exist?(CLOUD_CONFIG_PATH)
      config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
      config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    end
    
    config.vm.provision "shell", path: "provision.sh"
  end
end
