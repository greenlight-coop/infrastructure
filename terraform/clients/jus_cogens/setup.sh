#!/usr/bin/env bash

set -ex

terraform init

# Create client kind cluster
terraform apply -auto-approve -target=module.google_project.null_resource.update-kubeconfig

# Configure client cluster
