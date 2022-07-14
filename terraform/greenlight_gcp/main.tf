terraform {
  required_version = ">= 1.2.5"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 4.28.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    local = {
      source =  "hashicorp/local"
      version = "~> 2.2.3"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.3.2"
    }
  }

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "../credentials.json"
  }
}

provider "google" {
  credentials = "../credentials.json"
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
