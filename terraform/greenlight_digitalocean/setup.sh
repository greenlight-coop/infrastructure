#!/usr/bin/env bash

set -ex

wait_for_resource () {
  while : ; do
    kubectl -n $1 get $2 && break
    sleep 5
  done
  if [ -z $4 ]
  then
    kubectl -n $1 wait $2 --for=condition=$3 --timeout=600s
  else
    kubectl -n $1 wait $2 -l $4 --for=condition=$3 --timeout=600s
  fi
}

terraform init

# Install DigitalOcean cluster
terraform apply -auto-approve \
  -target=module.digitalocean.digitalocean_kubernetes_cluster.greenlight-development-cluster \
  -target=null_resource.kubeconfig
terraform apply -auto-approve \
  -target=module.digitalocean

# Install Argo CD
terraform apply -auto-approve -target=module.argo_cd
wait_for_resource argocd deployments Available app.kubernetes.io/part-of=argocd

# Install base cluster infrastructure
terraform apply -auto-approve -target=module.project_cluster
wait_for_resource istio-system deployments/istiod Available
wait_for_resource default deployments/loki-loki-distributed-distributor Available

# Install development cluster infrastructure
terraform apply -auto-approve -target=module.development_cluster_configuration
terraform apply -auto-approve