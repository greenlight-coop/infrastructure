# Green Light Development Platform - Local Kind Cluster Configuration

This configuration is intended for local testing of configuration changes.

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Manually generate the Let's Encrypt certificates and private key using the following command:

    sudo certbot -d 'apps-home.greenlightcoop.dev' -d '*.apps-home.greenlightcoop.dev' certonly --manual

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)
    export TF_VAR_webhook_secret=(Green Light GitHub webhook HMAC token value)
    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/privkey.pem)

### Create Kind Cluster

    terraform init \
        && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind_greenlight
        && terraform apply -auto-approve -target=module.kind_cluster

Install Argo CD and wait for all the services and pods to become available.

    terraform apply -auto-approve -target=module.argo_cd
    kubectl -n argocd get all