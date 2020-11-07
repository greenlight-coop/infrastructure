# Green Light Google Cloud Platform

## Prepare environment

Global for all instructions that follow

    gcloud auth application-default login
    export GCP_ORGANIZATION_ID=636256323415
    export SEED_GCP_PROJECT_ID=greenlight-seed
    export SEED_GCP_PROJECT_NAME=greenlight-seed
    export GCP_BILLING_ACCOUNT_ID=01614C-82BAE7-678369
    export TF_BACKEND_BUCKET=tfstate-greenlight
    export SEED_GCP_SERVICE_ACCOUNT=<lookup_fq_sa_username_after_creation>

## Initial Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

Run the following commands (once only for the Green Light organization)
    
    gcloud projects create $SEED_GCP_PROJECT_ID --name=$SEED_GCP_PROJECT_NAME --organization=$GCP_ORGANIZATION_ID --set-as-default

    ./setup-sa.sh -o $GCP_ORGANIZATION_ID -p $SEED_GCP_PROJECT_ID -b $GCP_BILLING_ACCOUNT_ID

    gsutil mb -b on -c nearline -p $SEED_GCP_PROJECT_ID gs://$TF_BACKEND_BUCKET

    gsutil versioning set on gs://$TF_BACKEND_BUCKET

    gsutil acl ch -u $SEED_GCP_SERVICE_ACCOUNT:OWNER gs://$TF_BACKEND_BUCKET

    terraform init \
        && tf apply -auto-approve -target=google_container_cluster.development \
        && tf apply -auto-approve -target=data.kubernetes_service.ingress-nginx-controller \
            -target=google_dns_record_set.api_name_servers \
            -target=google_dns_record_set.apps_name_servers \
            -target=google_dns_record_set.knative_name_servers \
            -target=google_dns_record_set.ingress_name_servers

Add the newly created Kubernetes cluster to your local configuration run:

    $(terraform output kubeconfig_command)

Look up the generated NS records for the api, apps, ingress and knative subdomains and add NS records for these name servers in the
Google Domains managed greenlightcoop.dev domain.

Build the remainder of the Terraform resources:

    terraform apply

Configure a webhook for the [greenlight-coop GitHub organization](https://github.com/organizations/greenlight-coop/settings/hooks/new)
* Copy the webhook_secret value from Terraform output
* Create the new GitHub webhook using webhook_secret as the Secret value and set .
    * Payload URL: https://argocd.apps[workspace].greenlightcoop.dev/api/webhook
    * Content type: application/json

## Update Configuration

    terraform apply

## Removal

    terraform destroy

### Remove Seed Project

It's expected this will never be required

    gcloud projects delete $SEED_GCP_PROJECT_ID --quiet

## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment (set of GCP projects) that can then be destroyed
after the modifications have been vetted and merged to master.

* Checkout a branch of the infrastructure and/or argocd-apps projects based on the current GitHub issue number.

        git checkout -b feature/<issue number>

* Create a new workspace using the issue number as part of the workspace name, replacing '/' with '-'

        terraform workspace new feature-<issue number>

* Iterate between deploying the resources in the new workspace and making changes to the configuration

        terraform apply
        $(terraform output kubeconfig_command)

* When all changes have been merged to master, dispose of the temporary workspace and apply changes to the 
  deafult workspace from master

        terraform destroy
        terraform workspace select default
        terraform workspace delete feature-<issue number>
        git checkout master && git pull
        terraform apply --var enable_dns_named_resources=false
        # Create DNS records for *-feature-<issue number> resources
        terraform apply apply