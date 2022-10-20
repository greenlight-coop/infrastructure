#!/usr/bin/env bash

# Run as root (sudo -i)
# 
# Uninstalls kubernetes and associated tools

set -ex

### remove packages
kubeadm reset -f || true
crictl rm --force $(crictl ps -a -q) || true
apt-mark unhold kubelet kubeadm kubectl kubernetes-cni || true
apt-get remove -y docker.io containerd kubelet kubeadm kubectl kubernetes-cni rpcbind nfs-kernel-server || true
apt-get autoremove -y
systemctl daemon-reload

### remove nfs
rm -f /etc/exports || true
rm -rf /srv/nfs/storage || true

### rm kubeconfig
rm /etc/kubernetes/admin.conf || true
rm /root/.kube/config || true
