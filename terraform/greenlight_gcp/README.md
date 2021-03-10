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
        -target=module.google_project \
        -target=null_resource.update-kubeconfig

Look up the generated NS records for the apps and knative subdomains and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

Install Argo CD and wait for all the services and pods to become available.

    terraform apply -auto-approve -target=module.argo_cd
    kubectl -n argocd get all
      
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
