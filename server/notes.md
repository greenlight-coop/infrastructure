# Installation

BIOS Boot Manager

* Hard Drive C:
  * Back USB: Innostor

## Set up

* English

* Ubuntu Server

* DHCP configured eno1

* No proxy

* Default Ubuntu mirror

* Installed on a single SSD

* Default storage config

* Open SSH
  * Install server
  * Import from GitHub (etavela)
  * Allow password auth over SSH

* Feature Server Snaps
  * Docker

## Kubernetes

run setup.sh

* As etavela
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes link node-role.kubernetes.io/control-plane:NoSchedule-

## Post set up

* Ensure current IP for link has port forwarding for HTTP and HTTPS in Verizon FiOS router

* As etavela
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo 'source <(kubectl completion zsh)' >> ~/.zshrc
  echo 'alias k=kubectl' >> ~/.zshrc

* Added user for mark

* Added mark to sudoers group
