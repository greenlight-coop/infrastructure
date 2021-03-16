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

* Add new cluster to Green Light Argo CD

      $(echo `terraform output argocd_cluster_add_command` | sed -e 's/^"//' -e 's/"$//')

* Update DNS to use assigned name servers for zone

* Update local kubeconfig

      gcloud config configurations activate <client profile name> 
      gcloud auth application-default login   # login as client project user
      $(echo `terraform output kubeconfig_command` | sed -e 's/^"//' -e 's/"$//')
      gcloud config configurations activate default 
      gcloud auth application-default login   # login as Green Light project user

* Complete cluster set up

      ./setup-cluster.sh