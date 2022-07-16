# Green Light Development Platform - Local kind Cluster Configuration

This configuration is intended for local testing of configuration changes.

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Ensure that the file `secrets.auto.tfvars` is present and contains correct values for:

    admin_password
    bot_github_token
    bot_password
    kind_tls_crt    # See Generating new certificates
    kind_tls_key    # See Generating new certificates
    snyk_token
    webhook_secret

Manually generate the Let's Encrypt certificates and private key using the directions below in the section
*Generating new certificates*

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

Revise `greenlight_kind/secrets.auto.tfvars` with updated keys:

    sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/fullchain.pem | pbcopy
    # Paste value into variable kind_tls_crt

    sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/privkey.pem | pbcopy
    # Paste value into variable kind_tls_key

### Configure kind Cluster

To run the automated set up script run:

    ./setup.sh

To manually install the kind cluster, run the steps below and then continue with configuration steps in the
main README.

    terraform init \
      && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind \
      && terraform apply -auto-approve -target=module.kind_cluster

## Removal

Run `./reset.sh` to remove resources and reset the workspace.