#!/usr/bin/env bash

set -ex

terraform init

# Configure GCP project and install GKE cluster
terraform apply -auto-approve -target=module.google_project -target=null_resource.update-kubeconfig

# Install Argo CD
terraform apply -auto-approve -target=module.argo_cd
kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s

# Install base cluster infrastructure
terraform apply -auto-approve -target=module.project_cluster
sleep 120
kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s
sleep 60
kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s

# Install development cluster infrastructure
terraform apply -auto-approve -target=module.development_cluster_configuration
terraform apply -auto-approve