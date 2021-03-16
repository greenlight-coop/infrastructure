#!/usr/bin/env bash

set -ex

terraform init

# Create client kind cluster
terraform apply -auto-approve -target=module.client_kind_cluster.null_resource.kind
terraform apply -auto-approve -target=module.client_kind_cluster

# Configure client cluster
