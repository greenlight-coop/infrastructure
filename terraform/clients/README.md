# Green Light Platform Client Projects

## Terraform Module

Create a new directory in the `clients` directory for the client Terraform project.

## Initial GCP Project

* Create an empty GCP project.

* Add terraform@greenlight-root.iam.gserviceaccount.com to IAM
  * Grant Owner role
  * Grant Service Account Token role

## Configure GCP Project and Cluster

* Initial project set up 

      ./setup-project.sh

* Update DNS to use assigned name servers for zone

* Update local kubeconfig

      gcloud config configurations activate <client profile name> 
      $(echo `terraform output kubeconfig_command` | sed -e 's/^"//' -e 's/"$//')

* Add new cluster to Green Light Argo CD (note: some auth and GCP configuration steps may be missing to correctly add cluster)

      argocd login \                                                           
        --username admin \
        --password <password> \
        --grpc-web \
        argocd.<app-subdomain>.greenlightcoop.dev

      argocd cluster add <new cluster context name>

      kubectl config use-context <greenlight cluster context name>
      gcloud config configurations activate default 

* Complete cluster set up

      ./setup-cluster.sh

## Configure GitHub

Grant `Owner` access to the organization and its repositories to the `greenlight-coop-bot` account.

Set up repository webhooks as described in the root README.md.

## Configure Docker Hub

Grant `owners` access to the `greenlightcoopbot` Docker Hub account.

## Clean Up

* Switch to client GCP project context, cleanup and switch back to default context

      gcloud config configurations activate <client profile name>   
      ./cleanup.sh
      gcloud config configurations activate default
