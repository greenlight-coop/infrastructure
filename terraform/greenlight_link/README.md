# Green Light Development Platform - link Cluster Configuration

This configuration runs on our local development server `link`.

## Install Ubuntu on link

Insert the USB drive containing the Ubuntu install image into the lower (right) USB slot
on the front of the server and reboot.

If necessary to reconfigure boot sequence
* Press F2 to open system set up
* Navigate to System BIOS > Boot Settings > BIOS Boot Settings
* Hard-Disk Drive Sequence
    * Make USB 1:Innostor first
* Save changes
* Exit and reboot

Choose the following settings:
* English
* Ubuntu Server
* DHCP configured eno1
* No proxy
* Default Ubuntu mirror
* Installed on a single SSD
* Default storage config
* Open SSH
  * Install server
  * Import from GitHub (etavela)
  * Allow password auth over SSH

Ensure current IP for link has port forwarding for HTTP and HTTPS in Verizon FiOS router

As etavela:

    sudo apt install zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

After cluster configuration:

    echo 'source <(kubectl completion zsh)' >> ~/.zshrc
    echo 'alias k=kubectl' >> ~/.zshrc

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Ensure that the file `secrets.auto.tfvars` is present and contains correct values for:

    admin_password
    bot_github_token
    bot_password
    tls_crt    # See Generating new certificates
    tls_key    # See Generating new certificates
    snyk_token
    webhook_secret

Manually generate the Let's Encrypt certificates and private key using the directions below in the section
*Generating new certificates*

### Configure link Cluster

To run the automated set up script run:

    bin/reset.sh <remote user>

#### Patch k8ssandra server-config-init limits

After deploying the K8ssandraCluster, fix OOMKilled issue with:

    kubectl patch -n k8ssandra-operator statefulset k8ssandra-dc1-default-sts --type json -p='[{"op": "replace", "path": "/spec/template/spec/initContainers/1/resources/limits/memory", "value":"512M"}]'

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

Log in to wireless router and temporarily route HTTP requests to Erics-MBP

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

Revise `greenlight_link/secrets.auto.tfvars` with updated keys:

    sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/fullchain.pem | pbcopy
    # Paste value into variable tls_crt

    sudo cat /etc/letsencrypt/live/app-home.greenlightcoop.dev/privkey.pem | pbcopy
    # Paste value into variable tls_key

Update certificate secret in cluster

    terraform apply -auto-approve -target=module.link_cluster.kubernetes_secret.istio-letsencrypt

Log in to wireless router restore forwarding of HTTP requests to link
