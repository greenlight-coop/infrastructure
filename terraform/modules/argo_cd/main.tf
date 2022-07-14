terraform {
  required_version = ">= 1.2.5"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.2.2"
    }
  }
}
