terraform {
  required_version = ">= 0.15.4"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.2.0"
    }
    k8s = {
      version = ">= 0.9.1"
      source  = "banzaicloud/k8s"
    }
  }
}