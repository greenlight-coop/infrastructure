terraform {
  required_version = ">= 1.1.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }
    linode = {
      source =  "linode/linode"
      version = "~> 1.25.2"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.1.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-greenlight"
    key    = "tfstate"
    region = "us-east-1"
    endpoint = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
  }
}

provider "linode" {
  token = var.linode_token
}

provider "kubernetes" { 
  config_path = "~/.kube/config"
}

provider "k8s" { 
  config_path = "~/.kube/config"
}

provider "helm" { 
  kubernetes {
    config_path = "~/.kube/config"
  }
}
