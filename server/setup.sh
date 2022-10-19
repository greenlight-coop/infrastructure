#!/usr/bin/env bash

# Run as root (sudo -i)
# 
# Installs/reinstalls kubernetes and associated tools
#
# To copy to link:
# scp setup.sh etavela@link:setup.sh

set -ex

KUBE_VERSION=1.24.7

### setup terminal
apt-get update
apt-get install -y bash-completion binutils
echo 'colorscheme ron' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias c=clear' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc

### disable linux swap and remove any existing swap partitions
swapoff -a
sed -i '/\sswap\s/ s/^\(.*\)$/#\1/g' /etc/fstab

### setup additional system packages
apt-get install -y net-tools
apt-get install -y zsh

### remove packages
kubeadm reset -f || true
crictl rm --force $(crictl ps -a -q) || true
apt-mark unhold kubelet kubeadm kubectl kubernetes-cni || true
apt-get remove -y docker.io containerd kubelet kubeadm kubectl kubernetes-cni rpcbind nfs-kernel-server || true
apt-get autoremove -y
systemctl daemon-reload

### remove nfs
rm -f /etc/exports || true

### sysctl settings
sysctl -w fs.inotify.max_user_instances=8192
sysctl -w fs.inotify.max_user_watches=1048576
sysctl -w vm.max_map_count=524288

cat <<EOF > /etc/sysctl.d/local.conf
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
vm.max_map_count = 524288
EOF

### install packages
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io containerd rpcbind nfs-kernel-server kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni
apt-mark hold kubelet kubeadm kubectl kubernetes-cni


### nfs
mkdir -p /srv/nfs/storage
chown -R nobody:nogroup /srv/nfs/storage
chmod 777 /srv/nfs/storage
echo '/srv/nfs/storage *(rw,sync,no_root_squash,no_subtree_check,no_all_squash,insecure)' >> /etc/exports
exportfs -ra
systemctl restart nfs-kernel-server

### containerd
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
mkdir -p /etc/containerd


### containerd config
cat > /etc/containerd/config.toml <<EOF
disabled_plugins = []
imports = []
oom_score = 0
plugin_dir = ""
required_plugins = []
root = "/var/lib/containerd"
state = "/run/containerd"
version = 2

[plugins]

  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      base_runtime_spec = ""
      container_annotations = []
      pod_annotations = []
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        BinaryName = ""
        CriuImagePath = ""
        CriuPath = ""
        CriuWorkPath = ""
        IoGid = 0
        IoUid = 0
        NoNewKeyring = false
        NoPivotRoot = false
        Root = ""
        ShimCgroup = ""
        SystemdCgroup = true
EOF


### crictl uses containerd as default
{
cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
}


### kubelet should use containerd
{
cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--container-runtime remote --container-runtime-endpoint unix:///run/containerd/containerd.sock"
EOF
}

### start services
systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd
systemctl enable kubelet && systemctl start kubelet


### init k8s
rm /root/.kube/config || true
kubeadm init --kubernetes-version=${KUBE_VERSION} --ignore-preflight-errors=NumCPU --skip-token-print --pod-network-cidr 10.0.0.0/8

mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config

### CNI
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml -O
sed -i 's/192.168.0.0\/16/10.0.0.0\/8/g' custom-resources.yaml
kubectl create -f custom-resources.yaml

### Wait for node
kubectl wait --for=condition=Ready node/link

### Make node schedulable
kubectl taint nodes link node-role.kubernetes.io/control-plane:NoSchedule- || true
kubectl taint nodes link node-role.kubernetes.io/master:NoSchedule- || true

### MetalLB
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
sed -e "s/mode: \"\"/mode: \"ipvs\"/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.6/config/manifests/metallb-native.yaml

kubectl wait -n metallb-system --timeout=180s --for condition=Available deployment/controller

HOST_IP=$(ip a s eno1 | awk '/inet / {print$2}' | cut -d/ -f1)

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: load-balancer-pool
  namespace: metallb-system
spec:
  addresses:
  - $HOST_IP/32
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - load-balancer-pool
EOF

### helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

### nfs storageclass
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=$HOST_IP \
  --set nfs.path=/srv/nfs/storage \
  --set storageClass.name=standard \
  --set storageClass.defaultClass=true \
  --set storageClass.volumeBindingMode=WaitForFirstConsumer
