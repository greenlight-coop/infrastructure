#!/usr/bin/env bash

set -ex

terraform init

# Install Linode cluster
terraform apply -auto-approve \
  -target=module.linode.linode_lke_cluster.greenlight-development-cluster \
  -target=null_resource.kubeconfig
terraform apply -auto-approve \
  -target=module.linode

# Install Argo CD
terraform apply -auto-approve -target=module.argo_cd
kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s

# Install base cluster infrastructure
terraform apply -auto-approve -target=module.project_cluster
while : ; do
  kubectl get -n istio-system deployments/istiod && break
  sleep 5
done
kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s
while : ; do
  kubectl get pods/loki-0 && break
  sleep 5
done
kubectl wait pods/loki-0 --for=condition=Ready --timeout=600s

# Install development cluster infrastructure
terraform apply -auto-approve -target=module.development_cluster_configuration
terraform apply -auto-approve