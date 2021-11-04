# Green Light GCP Project

## Initial Preparation

* Add terraform@greenlight-root.iam.gserviceaccount.com to IAM
  * Grant Owner role
  * Grant Service Account Token role

## Configure GCP Project and GKE Cluster

Configure the GCP project and install the GKE cluster with the following command:

    terraform init \
      && terraform apply -auto-approve \
        -target=module.google_project \
        -target=null_resource.update-kubeconfig

Look up the generated NS records for the app subdomain and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

## Removal

### Scripted

Run `./cleanup.sh`

### Manual

In GCP Console
* Delete cluster (wait for completion)
* Delete Record Sets and Zones in Cloud DNS
* Delete Load Balancers
* Check that all External IP Addresses are deleted (delete if necessary)
* Delete k8s_* Firewall Rules
* Delete Service Accounts
* Delete all Compute Engine Disks
* Delete all Compute Engine Instance Group Health Checks

If using a Terraform workspace for isolated cluster testing
* Delete Terraform workspace

        terraform workspace select default
        terraform workspace delete -force feature-<n>
