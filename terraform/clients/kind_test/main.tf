terraform {
  required_version = ">= 0.14.8"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.1.0"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "google" {
  credentials = "../../credentials.json"
}

provider "kubernetes" { 
  alias           = "client"
  config_path     = "~/.kube/config"
  config_context  = "kind-${local.client_name}"
}

provider "kubernetes" { 
  alias           = "greenlight"
  config_path     = "~/.kube/config"
  config_context  = "kind-greenlight"
}

provider "helm" { 
  kubernetes {
    config_path     = "~/.kube/config"
    config_context  = "kind-greenlight"
  }
}