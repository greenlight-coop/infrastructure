terraform {
  required_version = ">= 1.0.11"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.4.1"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
  }
}