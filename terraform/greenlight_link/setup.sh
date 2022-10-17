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

# Configure link cluster
terraform apply -auto-approve -target=module.link_cluster

# Install Argo CD
terraform apply -auto-approve -target=module.argo_cd
wait_for_resource argocd deployments Available app.kubernetes.io/part-of=argocd

# Install base cluster infrastructure
terraform apply -auto-approve -target=module.project_cluster
wait_for_resource istio-system deployments/istiod Available
wait_for_resource default pods/loki-0 Ready

# Install development cluster infrastructure
terraform apply -auto-approve -target=module.development_cluster_configuration
