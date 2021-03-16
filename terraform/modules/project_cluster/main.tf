terraform {
  required_version = ">= 0.14.8"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    k8s = {
      version = ">= 0.9.0"
      source  = "banzaicloud/k8s"
    }
  }
}