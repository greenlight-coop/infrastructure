#!/usr/bin/env bash

set -x

TF_WORKSPACE=$(terraform workspace show)

kind delete cluster --name test
rm -rf .terraform terraform.tfstate.d .terraform.lock.hcl
terraform workspace new $TF_WORKSPACE