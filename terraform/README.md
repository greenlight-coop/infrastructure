# Green Light Google Cloud Platform

## Initial Configuration

    gcloud auth application-default login

    export PROJECT_ID=greenlight-coop-development
    
    gcloud projects create $PROJECT_ID
    
    gcloud iam service-accounts \
        create devops-account \
        --project $PROJECT_ID \
        --display-name devops-account

    gcloud iam service-accounts \
        keys create account.json \
        --iam-account devops-account@$PROJECT_ID.iam.gserviceaccount.com \
        --project $PROJECT_ID

    gcloud projects \
        add-iam-policy-binding $PROJECT_ID \
        --member serviceAccount:devops-account@$PROJECT_ID.iam.gserviceaccount.com \
        --role roles/owner

    export TF_VAR_project_id=$PROJECT_ID
        
    terraform init

Note that credentials downloaded as account.json can't be regenerated and are git ignored and should be protected
accordingly.