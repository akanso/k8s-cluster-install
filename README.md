---
layout: post
title:  "Deploying a k8s cluster on a single machine"
date:   2019-06-14 10:00:39 -0400
author: Ali Kanso
---
## Objective
The objective of this repo is to help you deploy a k8s cluster of one master and multiple workers on a local machine in *one click!*
The target audience are developpers that want a testing environment to work with.

## Deploying a k8s-cluster using kube-adm on vagrant

### Prerequisites (before you start k8s deployment):

Start by cloning this repo:

`git clone https://github.com/akanso/k8s-cluster-install.git`

Make sure you have [`virtualbox`](https://www.virtualbox.org/wiki/Downloads) installed on your machine (tested on versions >= 6.0).

Make sure you have [`vagrant`](https://www.vagrantup.com/downloads.html) installed (tested on 1.8, 2.0, and 2.2.4).

### Provisioning the VMs and deploy k8s (all in one install):

Simply move to the directory where the `Vagrantfile` resides and execute a vagrant up command:

```shell
cd k8s-cluster-install
vagrant up
```

This should take a few minutes, after which one master and 2 worker k8s nodes will be deployed

```shell
vagrant status

master-node               running (virtualbox)
worker-node1              running (virtualbox)
worker-node2              running (virtualbox)
```

you can `ssh` into the master-node and check the cluster status:

```shell
vagrant ssh master-node
sudo su
kubectl get nodes
```
You should see that your nodes are up and ready. (it might take a minute to get to the ready state)

```shell
kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
master-node    Ready    master   46m   v1.15.0
worker-node1   Ready    worker   44m   v1.15.0
worker-node2   Ready    worker   42m   v1.15.0
```

## Customizing the k8s deployment and the number/size of the VMs

The configuration file [vg_config.rb](https://github.com/akanso/k8s-cluster-install/blob/master/vg_config.rb) is also 

You can change the values of all the variables in this file, e.g.:

```shell
cat vg_config.rb
$worker_vm_count=2
$worker_vm_memory=1536
$worker_vm_cpu=1
...
```

For example, you can set the `worker_vm_count` to `3` and run `vagrant up` again. This will create and extra worker VM (leaving the existing one intact), install kubernetes of that woker, and join it to the existing k8s cluster.

You can customize the k8s installation by modifying the content of the [`kube-master-start.sh`](https://github.com/akanso/k8s-cluster-install/blob/master/kube-master-start.sh).
for instance you can change the `--pod-network-cidr=192.168.0.0/16` according to your network config, if needed.

## To cleanup the VMs

to remove all the VMs:

`yes | vagrant destroy -f`
