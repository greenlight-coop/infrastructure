terraform {
  required_version = ">= 1.3.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
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
