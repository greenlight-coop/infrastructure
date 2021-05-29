terraform {
  required_version = ">= 0.15.4"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
  }
}
