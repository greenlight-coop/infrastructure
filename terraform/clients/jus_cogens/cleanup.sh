#!/usr/bin/env bash

set -x

TF_WORKSPACE=$(terraform workspace show)
GCP_PROJECT_ID=$(terraform output project_id | sed -e 's/^"//' -e 's/"$//')
DNS_ZONE_NAME=$(terraform output dns_zone_name | sed -e 's/^"//' -e 's/"$//')

# Delete DNS records and zones
gcloud --project=$GCP_PROJECT_ID --quiet dns record-sets import -z $DNS_ZONE_NAME --delete-all-existing /dev/null
gcloud --project=$GCP_PROJECT_ID --quiet dns managed-zones delete $DNS_ZONE_NAME

# Delete service accounts
gcloud --project=$GCP_PROJECT_ID --quiet iam service-accounts delete dns-admin@$GCP_PROJECT_ID.iam.gserviceaccount.com

# Delete Cluster
gcloud --project=$GCP_PROJECT_ID --quiet container clusters delete jus-cogens-prod-cluster

# * Delete firewall rules and external IP addresses
firewalls=$(gcloud "--project=$GCP_PROJECT_ID" compute firewall-rules list \
        --format='value(name)' \
        --filter="name ~ ^k8s-fw- AND -tags gke-jus-cogens-prod-cluster-")
for firewall in $firewalls; do
  id=$(sed 's/.*k8s-fw-\([a-z0-9]\{32\}\).*/\1/' <<<"${firewall}")
  gcloud compute "--project=$GCP_PROJECT_ID" -q firewall-rules   delete "k8s-fw-${id}"
  gcloud compute "--project=$GCP_PROJECT_ID" -q forwarding-rules delete "${id}"
  gcloud compute "--project=$GCP_PROJECT_ID" -q target-pools delete "${id}"
  gcloud compute "--project=$GCP_PROJECT_ID" -q addresses delete "${id}"
done

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
