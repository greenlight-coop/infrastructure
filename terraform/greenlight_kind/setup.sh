#!/usr/bin/env bash

set -ex

terraform init

# Create kind cluster
terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind
terraform apply -auto-approve -target=module.kind_cluster

# Install Argo CD
terraform apply -auto-approve -target=module.argo_cd
kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s

# Install k8ssandra
terraform apply -auto-approve -target=module.k8ssandra

# Install base cluster infrastructure
terraform apply -auto-approve -target=module.base_cluster_configuration
sleep 120
kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s
sleep 30
kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s

# Install development cluster infrastructure
terraform apply -auto-approve -target=module.development_cluster_configuration