terraform {
  required_version = ">= 1.1.6"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.17.1"
    }
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
    endpoint = "nyc3.digitaloceanspaces.com"
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "kubernetes" {
  host                    = module.digitalocean.kubernetes_host
  token                   = module.digitalocean.kubernetes_token
  cluster_ca_certificate  = module.digitalocean.kubernetes_cluster_ca_certificate
}

provider "k8s" { 
  host                    = module.digitalocean.kubernetes_host
  token                   = module.digitalocean.kubernetes_token
  cluster_ca_certificate  = module.digitalocean.kubernetes_cluster_ca_certificate
}

provider "helm" { 
  kubernetes {
    host                    = module.digitalocean.kubernetes_host
    token                   = module.digitalocean.kubernetes_token
    cluster_ca_certificate  = module.digitalocean.kubernetes_cluster_ca_certificate
  }
}
