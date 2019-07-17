#!/bin/bash

NETWORK=""
GATEWAY=""
KUBE_VERSION=""
#################################################
# initialize
#################################################
initialize(){
    echo "    ------ initializing variables-----    "

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

    if [ "$3" = "" ]; then
    echo "no KUBE_VERSION setting, defaulting to v1.15"
    KUBE_VERSION="v1.15.0"
    else 
        KUBE_VERSION=$3
    fi
}

#################################################
# install k8s 
#################################################
install_k8s(){

    if [ "$NETWORK" = "CALICO" ]; then
        echo "using calico networking"
        kubeadm init  --kubernetes-version $KUBE_VERSION --apiserver-advertise-address=$GATEWAY --pod-network-cidr=10.240.0.0/16 --token-ttl 0 | tee token.sh
    else
        kubeadm init  --kubernetes-version $KUBE_VERSION --pod-network-cidr=10.240.0.0/16 --apiserver-advertise-address=$GATEWAY --token-ttl 0 | tee token.sh 
    fi

        echo "$(tail -n 2 token.sh)" > token.sh
        chmod +x token.sh
        yes | cp -rf -i token.sh /vagrant/token.sh
        mkdir -p $HOME/.kube
        yes | cp -rf -i /etc/kubernetes/admin.conf $HOME/.kube/config
        yes | cp -rf -i /etc/kubernetes/admin.conf /vagrant/kube.conf
        yes | mv -f token.sh $HOME/.kube/token.sh
        chown $(id -u):$(id -g) $HOME/.kube/config
        kubectl taint nodes --all node-role.kubernetes.io/master-

    if [ "$NETWORK" = "CANAL" ]; then
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml

    elif [ "$NETWORK" = "CALICO" ]; then # using calico
         KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml

    else
        KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter-all-features.yaml
        KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n kube-system delete ds kube-proxy
        docker run --privileged --net=host gcr.io/google_containers/kube-proxy-amd64:v1.7.3 kube-proxy --cleanup-iptables
    fi

    kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
    echo -e "\nuse the following command on the worker nodes to join the cluster: \n"
    cat $HOME/.kube/token.sh
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
[ `whoami` = root ] || exec su -c $0 root

trap ctrl_c INT

initialize $1 $2 $3

install_k8s
