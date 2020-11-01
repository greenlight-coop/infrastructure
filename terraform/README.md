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
    
    gcloud projects create $SEED_GCP_PROJECT_ID --name=$SEED_GCP_PROJECT_NAME --organization=$GCP_ORGANIZATION_ID --set-as-default

    ./setup-sa.sh -o $GCP_ORGANIZATION_ID -p $SEED_GCP_PROJECT_ID -b $GCP_BILLING_ACCOUNT_ID

    gsutil mb -b on -c nearline -p $SEED_GCP_PROJECT_ID gs://$TF_BACKEND_BUCKET

    gsutil versioning set on gs://$TF_BACKEND_BUCKET

    gsutil acl ch -u $SEED_GCP_SERVICE_ACCOUNT:OWNER gs://$TF_BACKEND_BUCKET

    terraform init

    terraform apply

(TBD - document DNS configuration steps)

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

* Checkout a branch of the infrastructure project based on the current GitHub issue.

        git checkout -b feature/<n>

* Create a new workspace using the issue number as part of the workspace name

        terraform workspace new temp<n>

* Iterate between deploying the resources in the new workspace and making changes to the configuration

        terraform apply

* When all changes have been merged to master, dispose of the temporary workspace and apply changes from master

        terraform destroy
        terraform workspace select default
        terraform workspace delete temp<n>
        git checkout master && git pull
        terraform apply