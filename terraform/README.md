# Green Light Google Cloud Platform

## Initial Configuration

    gcloud auth application-default login
        
    terraform init

    terraform apply

## Update Configuration

    terraform apply --var project_id=$(terraform output project_id)

## Removal

    terraform destroy --var project_id=$(terraform output project_id)