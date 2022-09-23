# Installation

BIOS Boot Manager

* Hard Drive C:
  * Back USB: Innostor

## Set up

* English

* Ubuntu Server

* DHCP configured eno4

* No proxy

* Default Ubuntu mirror

* Installed on a single SSD

* Default storage config

* Open SSH
  * Install server
  * Import from GitHub (etavela)
  * Allow password auth over SSH

* Feature Server Snaps
  * None

## Post set up

* Added user for mark

* apt-get install zsh

* Added mark to sudoers group

## Kubernetes

* apt-get kubeadm, etc.
  * Should do this after container runtime and CNI...

* Chose CRI-O as container runtime
  * BAILED - switched to containerd

* containerd
  * Followed instructions (option 1)
  * containerd config default > /etc/containerd/config.toml
  * Set [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
  * "When using kubeadm, manually configure the cgroup driver for kubelet." (?)

* Configured CNI using Udemy CKS install_master.sh approach
  * cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf...
  * cat <<EOF | sudo tee /etc/default/kubelet
  * apt-get install kubernetes-cni
  * apt-mark hold kubernetes-cni
  * kubeadm init --pod-network-cidr 192.168.0.0/16

* As etavela
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/calico.yaml

kubectl taint nodes link node-role.kubernetes.io/control-plane:NoSchedule-
