terraform {
  required_version = ">= 1.1.6"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}
