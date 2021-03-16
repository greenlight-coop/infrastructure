#!/usr/bin/env bash

set -ex

terraform init

# Create client kind cluster
terraform apply -auto-approve -target=module.google_project -target=output.argocd_cluster_add_command