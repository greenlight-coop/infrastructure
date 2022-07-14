terraform {
  required_version = ">= 1.2.5"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.1"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.2.3"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.3.2"
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
