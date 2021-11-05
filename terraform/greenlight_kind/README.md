# Green Light Development Platform - Local kind Cluster Configuration

This configuration is intended for local testing of configuration changes.

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Manually generate the Let's Encrypt certificates and private key using the following command:

    sudo certbot -d 'app-home.greenlightcoop.dev' -d '*.app-home.greenlightcoop.dev' certonly --manual

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/privkey.pem)

### Configure kind Cluster

To run the automated set up script run:

    ./setup.sh

To manually install the kind cluster, run the steps below and then continue with configuration steps in the
main README.

    terraform init \
      && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind \
      && terraform apply -auto-approve -target=module.kind_cluster

## Generating new certificates

    sudo certbot -d 'app-home.greenlightcoop.dev' -d '*.app-home.greenlightcoop.dev' certonly --manual

When prompted as below:

    Please deploy a DNS TXT record under the name
    _acme-challenge.app-home.greenlightcoop.dev with the following value:

    OZdKS2pomMFKHtBiNrmKr8WrrG3VVXie0_pCWYiDWX8

    Before continuing, verify the record is deployed.

Add a DNS TXT record for _acme-challenge.app-home with the given value to the greenlightcoop.dev DNS domain 
in Google domains.

When prompted as below:

    Create a file containing just this data:

    08mVPwxIndZaT9nV6Tv9RoHojBFDE5HEhT5TctzfuTc.T_6u_nBYdeE7_TZa4wLxpoHzct2rAzHnMvdTTSDxDZs

    And make it available on your web server at this URL:

    http://app-home.greenlightcoop.dev/.well-known/acme-challenge/08mVPwxIndZaT9nV6Tv9RoHojBFDE5HEhT5TctzfuTc

    (This must be set up in addition to the previous challenges; do not remove,
    replace, or undo the previous challenge tasks yet.)

Deploy an nginx container

    sudo docker run -d -p 80:80 nginx

Open a shell

    docker container ls -a
    docker exec -it <container name> bash

Add the verification data string to the expected path

    cd /usr/share/nginx/html/
    mkdir -p .well-known/acme-challenge
    cd .well-known/acme-challenge/
    echo <verification string> > <verification file path>
    exit

Press Enter to complete verification

Remove nginx docker container

    docker container stop <container name>
    docker container rm <container name>

Export updated keys:

    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/privkey.pem)

## Removal

Run `./reset.sh` to remove resources and reset the workspace.