#!/usr/bin/env bash

set -ex

TF_WORKSPACE=$(terraform workspace show)
GCP_PROJECT_ID=$(terraform output project_id | sed -e 's/^"//' -e 's/"$//')
DNS_ZONE_NAME=$(terraform output dns_zone_name | sed -e 's/^"//' -e 's/"$//')

gcloud --project=$GCP_PROJECT_ID --quiet dns record-sets import -z $DNS_ZONE_NAME --delete-all-existing /dev/null
gcloud --project=$GCP_PROJECT_ID --quiet dns managed-zones delete $DNS_ZONE_NAME
gcloud --project=$GCP_PROJECT_ID --quiet iam service-accounts delete dns-admin@$GCP_PROJECT_ID.iam.gserviceaccount.com
gcloud --project=$GCP_PROJECT_ID --quiet container clusters delete greenlight-development-cluster
# * Delete Load Balancers
# * Check that all External IP Addresses are deleted (delete if necessary)
# * Delete k8s_* Firewall Rules
# * Delete Service Accounts
# * Delete all Compute Engine Disks
# * Delete all Compute Engine Instance Group Health Checks

terraform workspace select default
terraform workspace delete -force $TF_WORKSPACE
