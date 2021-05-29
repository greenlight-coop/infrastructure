terraform {
  required_version = ">= 0.15.4"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.2.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}