#!/usr/bin/env bash

set -x

TF_WORKSPACE=$(terraform workspace show)
GCP_PROJECT_ID=$(terraform output project_id | sed -e 's/^"//' -e 's/"$//')
DNS_ZONE_NAME=$(terraform output dns_zone_name | sed -e 's/^"//' -e 's/"$//')

gcloud --project=$GCP_PROJECT_ID --quiet dns record-sets import -z $DNS_ZONE_NAME --delete-all-existing /dev/null
gcloud --project=$GCP_PROJECT_ID --quiet dns managed-zones delete $DNS_ZONE_NAME
gcloud --project=$GCP_PROJECT_ID --quiet iam service-accounts delete dns-admin@$GCP_PROJECT_ID.iam.gserviceaccount.com
gcloud --project=$GCP_PROJECT_ID --quiet container clusters delete jus-cogens-prod-cluster

# TBD
# See https://github.com/pantheon-systems/kube-gce-cleanup
# * Delete Load Balancers
# * Check that all External IP Addresses are deleted (delete if necessary)
# * Delete k8s_* Firewall Rules
# * Delete Service Accounts
# * Delete all Compute Engine Instance Group Health Checks

# * Delete all unused Compute Engine Disks
for orphaned_disk_uri in $(gcloud --project=$GCP_PROJECT_ID compute disks list --uri --filter="-users:*" 2> /dev/null); do
  orphaned_disk_name=${orphaned_disk_uri##*/}
  orphaned_disk_zone_uri=${orphaned_disk_uri/\/disks\/${orphaned_disk_name}/}
  orphaned_disk_zone=${orphaned_disk_zone_uri##*/}
  if [ -n "${orphaned_disk_name}" ] && [ -n "${orphaned_disk_zone}" ] && gcloud --project=$GCP_PROJECT_ID compute disks delete ${orphaned_disk_name} --zone ${orphaned_disk_zone} --quiet; then
    echo "deleted: ${orphaned_disk_zone}/${orphaned_disk_name}"
  fi
done

terraform workspace select default
terraform workspace delete -force $TF_WORKSPACE
