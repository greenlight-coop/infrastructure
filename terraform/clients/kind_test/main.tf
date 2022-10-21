terraform {
  required_version = ">= 1.3.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
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
      version = "~> 3.4.3"
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
