# Installation

BIOS Boot Manager

* Hard Drive C:
  * Back USB: Innostor

## Set up

* Installation USB in lower (right side) slot

* Configure boot (if necessary)
  * F2 system set up
  * System BIOS > Boot Settings > BIOS Boot Settings
    * Hard-Disk Drie Sequence
      * Make USB 1:Innostor first
  * Save changes
  * Exit and reboot

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

## On MacBook

scp etavela@link:.kube/config ~/.kube/config

## Reset instructions

On MacBook, in `server` directory, copy latest setup

    scp setup.sh etavela@link:setup.sh

On `link` as `etavela`

    sudo -i
    cd ~etavela && ./setup.sh
    exit
    mkdir -p ~/.kube/ && sudo cp -f /etc/kubernetes/admin.conf ~/.kube/config && sudo chown etavela ~/.kube/config

On MacBook get kubeconfig

    scp etavela@link:.kube/config ~/.kube/config

On MacBook, in `greenlight_link` directory, deploy Green Light platform

    TF_WORKSPACE=feature-nnn
    rm -rf .terraform.lock.hcl terraform.tfstate*
    terraform workspace new $TF_WORKSPACE
    ./setup.sh

## NGINX notes

sudo apt install nginx