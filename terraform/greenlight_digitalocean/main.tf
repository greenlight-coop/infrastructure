terraform {
  required_version = ">= 1.0.5"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.15.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.4.1"
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
    region = "nyc3"
    endpoint = "nyc3.digitaloceanspaces.com"
    skip_credentials_validation = true
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
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
