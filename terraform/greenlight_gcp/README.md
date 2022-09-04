# Green Light GCP Project

## Initial Preparation

* Add terraform@greenlight-root.iam.gserviceaccount.com to IAM
  * Grant Owner role
  * Grant Service Account Token role

## greenlight-root GCP Project

All cross-project GCP resources are configured in the `greenlight-root` project. This project was created manually and includes

* The `tfstate-greenlight` bucket that holds Terraform state for all GCP involved projects
* The `terraform` Service Account used for creation and access for Terraform managed resources.
    * terraform@greenlight-root.iam.gserviceaccount.com
    * Give Owner role access to the `greenlight-root`, `greenlight-coop-development` and all feature and client GCP projects
    * Give Service Account Token Creator role in `greenlight-root`, `greenlight-coop-development` and all feature and client 
      GCP projects in order to allow use in Terraform.
    * Generated a JSON key and saved to the root of `terraform` as `credentials.json`

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
