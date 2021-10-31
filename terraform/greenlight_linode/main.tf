terraform {
  required_version = ">= 1.0.5"

  required_providers {
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
    linode = {
      source =  "linode/linode"
      version = "~> 1.22.0"
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
    key    = "/tfstate"
    region = var.region
    endpoint = "${var.region}.linodeobjects.com"
    skip_credentials_validation = true
    access_key = var.tfstate_access_key
    secret_key = var.tfstate_secret_key
  }
}

provider "linode" {
  token = var.terraform_token
}

provider "kubernetes" { 
  host                    = "https://${module.google_project.cluster_endpoint}"
  token                   = module.google_project.access_token
  cluster_ca_certificate  = module.google_project.cluster_ca_certificate
}

provider "k8s" { 
  host                    = "https://${module.google_project.cluster_endpoint}"
  token                   = module.google_project.access_token
  cluster_ca_certificate  = module.google_project.cluster_ca_certificate
}

provider "helm" { 
  kubernetes {
    host                    = "https://${module.google_project.cluster_endpoint}"
    token                   = module.google_project.access_token
    cluster_ca_certificate  = module.google_project.cluster_ca_certificate
  }
}
