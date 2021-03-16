# Green Light Development Platform - Local kind Cluster Configuration

This configuration is intended for local testing of configuration changes.

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Manually generate the Let's Encrypt certificates and private key using the following command:

    sudo certbot -d 'apps-home.greenlightcoop.dev' -d '*.apps-home.greenlightcoop.dev' certonly --manual

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/privkey.pem)

### Configure kind Cluster

Install the kind cluster

    terraform init \
      && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind \
      && terraform apply -auto-approve -target=module.kind_cluster

## Removal

Run `./reset.sh` to remove resources and reset the workspace.