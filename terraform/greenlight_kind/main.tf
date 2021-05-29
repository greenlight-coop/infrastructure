terraform {
  required_version = ">= 0.15.4"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    k8s = {
      version = ">= 0.9.0"
      source  = "banzaicloud/k8s"
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

provider "kubernetes" { 
  config_path = "~/.kube/config"
  config_context = "kind-greenlight"
}

provider "k8s" { 
  config_path = "~/.kube/config"
  config_context = "kind-greenlight"
}

provider "helm" { 
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "kind-greenlight"
  }
}
