#!/usr/bin/env bash

set -ex

TF_WORKSPACE=$(terraform workspace show)
GCP_PROJECT_ID=$(terraform output project_id)

gcloud --project=$GCP_PROJECT_ID container clusters delete greenlight-development-cluster
# gcloud --project=$GCP_PROJECT_ID dns record-sets transaction remove -z my-zone --name "some_domain.com." --ttl 300 --type TXT "test"
# * Delete Zone in Cloud DNS
# * Delete Load Balancers
# * Check that all External IP Addresses are deleted (delete if necessary)
# * Delete k8s_* Firewall Rules
# * Delete Service Accounts
# * Delete all Compute Engine Disks
# * Delete all Compute Engine Instance Group Health Checks

terraform workspace select default
terraform workspace delete -force $TF_WORKSPACE
