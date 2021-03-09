# Green Light Development Platform

## Deploy Green Light Development Platform

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)
    export TF_VAR_webhook_secret=(Green Light GitHub webhook HMAC token value)

### Configure GCP Project and GKE Cluster

Configure the GCP project and install the GKE cluster with the following command:

    terraform init \
      && terraform apply -auto-approve \
        -target=module.google_project.google_container_cluster.cluster \
        -target=module.google_project.google_dns_record_set.domain_name_servers \
        -target=null_resource.update-kubeconfig

Look up the generated NS records for the apps and knative subdomains and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

    terraform apply -auto-approve

## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment (GCP project and cluster) that can then be destroyed
after the modifications have been vetted and merged to master.

* Create a new Terraform workspace, checkout a branch of all repositories based on the current GitHub issue number 
  and push to GitHub.

      meta git checkout -b feature/<n>
      meta git push origin --set-upstream feature/<n>
      terraform init
      terraform workspace new feature-<n> 

* Follow the Deploy Green Light Development Platform instructions given earlier in this README.

* Iterate between deploying the resources in the new workspace and making changes to the configuration

* When all changes have been merged to master, dispose of the temporary workspace and apply changes to the 
  default workspace from master

      meta git fetch --all
      meta git checkout master
      meta git pull
      meta git branch -D feature/<n>
      meta git push origin --delete feature/<n>
      terraform workspace select default
      terraform workspace delete -force feature-<n>
      
## Remove Green Light Development Platform

    terraform destroy -auto-approve 

## Manual Removal

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
