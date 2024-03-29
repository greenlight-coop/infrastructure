# Green Light DigitalOcean Project

## Initial Preparation

* Create `tfstate-project` project to maintain Terraform state
* Create a token `digitalocean_token` and save the value
* Set up Space `tfstate-greenlight` and access keys for Terraform backend in `tfstate-project` project
* `brew install doctl`
* `doctl auth init`
    * Provide token created above when asked

## Configure DigitalOcean Cluster

Configure the DigitalOcean Kubernetes cluster with the following command:

    ./setup.sh

Look up the generated NS records for the app subdomain and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

## Removal

Run:

    ./cleanup.sh

Ensure all Droplets, Volumes, Domains, Firewalls and Load Balances are removed