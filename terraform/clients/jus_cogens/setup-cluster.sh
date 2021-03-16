#!/usr/bin/env bash

set -ex

terraform init

# Configure project cluster
terraform apply -auto-approve