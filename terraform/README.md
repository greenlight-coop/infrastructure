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

    terraform apply --var project_id=$(terraform output project_id)

## Removal

    terraform destroy --var project_id=$(terraform output project_id)

### Remove Seed Project

It's expected this will never be required

    gcloud projects delete $SEED_GCP_PROJECT_ID --quiet