terraform {
  required_version = ">= 1.3.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
  }
}
