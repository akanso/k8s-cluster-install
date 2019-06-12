#Specifying the number and resource configuration of the master VMs

$master_vm_memory=2048
$master_vm_cpu=2

#Specifying the number and resource configuration of the worker VMs
$worker_vm_count=2
$worker_vm_memory=1536
$worker_vm_cpu=1



#Vagrant box to use for all the VMs.
#See https://www.vagrantup.com/docs/boxes.html about what boxes are available.

#$thebox="ubuntu/xenial64" #for ubuntu 16
$thebox="ubuntu/bionic64" #for ubuntu 18
