# Green Light Linode Project

## Initial Preparation

* Set up Object Storage Bucket and Access Keys for Terraform backend

## Configure Linode Cluster

Configure the Linode LKE cluster with the following command:

    ./setup.sh

Look up the generated NS records for the apps subdomain and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

## Removal


Run:

    ./cleanup.sh
