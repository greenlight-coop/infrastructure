#!/usr/bin/env bash

set -ex

terraform init

# Create client GCP project and GKE cluster
terraform apply -auto-approve -target=module.google_project