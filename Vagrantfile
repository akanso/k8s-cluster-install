# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'
require 'pathname'

# create a k8s cluster v1.8.1 using kubeadm:
# http://kubernetes.io/docs/getting-started-guides/kubeadm/


# making sure the dependencies exist
unless Vagrant.has_plugin?("vagrant-hostmanager")
  system("vagrant plugin install vagrant-hostmanager")
  puts "Hostmanager dependencies installed!, try the command again now"
  exit
end

# creating keys allowing inter-cluster ssh
if ARGV[0] == "up"
    puts "Info: attempting to create ssh keys"
    system('./keys/create-keys.sh')
    system('touch token.sh')
end

# Checking if a configuration file exists, if it does, then read its attribute values
# Otherwise use default values

pn = Pathname.new("./vg_config.rb")
CONFIG = File.expand_path(pn)
if File.exist?(CONFIG)
  require CONFIG
  puts "Info: vagrant_config file is found, and will be used" if ARGV[0] == "up"

  MASTER_VM_COUNT=1
  MASTER_VM_MEMORY=$master_vm_memory
  MASTER_VM_CPU=$master_vm_cpu

  WORKER_VM_COUNT=$worker_vm_count
  WORKER_VM_MEMORY=$worker_vm_memory
  WORKER_VM_CPU=$worker_vm_cpu


  THE_BOX=$thebox

else
  puts "Info: vagrant_config file is missing, vagrant will use default values" if ARGV[0] == "up"

  MASTER_VM_COUNT=1
  MASTER_VM_MEMORY=2048
  MASTER_VM_CPU=2

  WORKER_VM_COUNT=2
  WORKER_VM_MEMORY=1024
  WORKER_VM_CPU=1

  THE_BOX="ubuntu/bionic64"
end

Vagrant.configure("2") do |config|
  config.vm.box = THE_BOX
  config.vm.box_check_update = false

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  
  config.ssh.insert_key = 'true'
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"


  config.vm.define "master-node" do |c|
      c.vm.hostname = "master-node"
      c.vm.network "private_network", ip: "192.168.10.2"
      c.vm.network "forwarded_port", guest: 30001, host: 30001
      # Copy the ssh keys to the vm
      if File.exists?(File.expand_path("./keys/id_rsa"))
        # This is the default and serve just as a reminder
        c.vm.synced_folder ".", "/vagrant"
        c.vm.provision "shell",
          inline: "cp /vagrant/keys/id_rsa /home/vagrant/.ssh/id_rsa"        
      end
      if File.exists?(File.expand_path("./keys/id_rsa.pub"))
        c.vm.provision "shell",
          inline: "cp /vagrant/keys/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub"
      end
      config.vm.provision "shell",
        inline: "if [ -e /home/vagrant/.ssh/id_rsa.pub ]; then cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys;fi"
      
      system('chmod +x ./kube-install.sh')
      system('chmod +x ./kube-master-start.sh')

      c.vm.provision :shell, :path => "kube-install.sh"
      c.vm.provision :shell, :path => "kube-master-start.sh"

      config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.cpus = MASTER_VM_CPU
        vb.memory = MASTER_VM_MEMORY
      end
    end

  # create worker nodes
  
  (1..WORKER_VM_COUNT).each do |i|
    config.vm.define "worker-node#{i}" do |node|
        node.vm.hostname = "worker-node#{i}"
        node.vm.network "private_network", ip: "192.168.10.#{i+2}"
        node.vm.network "forwarded_port", guest: "909#{i}", host: "909#{i}"
        # Copy the ssh keys to the vm
        if File.exists?(File.expand_path("./keys/id_rsa"))
          node.vm.synced_folder ".", "/vagrant"
          node.vm.provision "shell",
            inline: "cp /vagrant/keys/id_rsa /home/vagrant/.ssh/id_rsa"             
        end
        if File.exists?(File.expand_path("./keys/id_rsa.pub"))
          node.vm.provision "shell",
          inline: "cp /vagrant/keys/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub"
        end
        node.vm.provision :shell, :path => "kube-install.sh"
        if File.exists?(File.expand_path("./token.sh"))
          system('chmod +x ./token.sh')
          node.vm.provision :shell, :path => "token.sh"         
        end

        config.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.cpus = WORKER_VM_CPU
            vb.memory = WORKER_VM_MEMORY
        end
    end
  end
end

