terraform {
  required_version = ">= 0.14.8"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}
