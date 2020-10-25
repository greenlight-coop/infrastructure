# Green Light Google Cloud Platform

## Initial Configuration

    gcloud auth application-default login
        
    terraform init

    terraform apply

Create/update NS records for dev.greenlight.coop. at https://marcaria.com/ from output

## Update Configuration

    terraform apply --var project_id=$(terraform output project_id)

## Removal

    terraform destroy --var project_id=$(terraform output project_id)