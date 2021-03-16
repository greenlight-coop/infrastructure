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
      gcloud config configurations activate default 
      kubectl config use-context <greenlight cluster context name>

* Add new cluster to Green Light Argo CD

      argocd login \                                                           
        --username admin \
        --password <password> \
        --grpc-web \
        argocd.<apps-subdomain>.greenlightcoop.dev

      argocd cluster add <new cluster context name>

* Complete cluster set up

      ./setup-cluster.sh