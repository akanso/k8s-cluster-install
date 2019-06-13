#!/bin/bash

NETWORK= ""
GATEWAY= ""

#################################################
# initialize
#################################################
initialize(){
echo -e "
------ initializing variables-----
"

if [ "$1" = "" ]; then
echo "no NETWORK setting, defaulting to CALICO"
NETWORK="CALICO"
else 
    NETWORK=$1
fi

if [ "$2" = "" ]; then
echo "no GATEWAY setting, defaulting to 192.168.10.2"
GATEWAY="192.168.10.2"
else 
    GATEWAY=$2
fi
}

#################################################
# intsall Docker, kubelet, kubeadm, kubectl
#################################################
intsall_kube-adm(){

echo "installing kube-adm"
modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
apt-get update
apt install -y ebtables ethtool
apt-get install -y docker.io
apt-get install -y curl apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable
EOF
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

if [ "$NETWORK" = "CALICO" ]; then
    echo "using calico networking"
    route add 10.96.0.1 gw $GATEWAY
fi
}


#################################################
#ctrl_c:
#################################################
function ctrl_c() {
    cleanup
    echo -e "
 ________________________________________
|    stopping the script, good bye!    |
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                
                ||     ||
"
    exit 1
}
#################################################
#flow:
#################################################
[ `whoami` = root ] || exec sudo su

trap ctrl_c INT

initialize $1 $2 


intsall_kube-adm


