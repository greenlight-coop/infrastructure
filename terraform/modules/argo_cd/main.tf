terraform {
  required_version = ">= 1.3.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.2.3"
    }
  }
}
