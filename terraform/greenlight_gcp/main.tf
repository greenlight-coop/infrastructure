terraform {
  required_version = ">= 0.15.4

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
    google = {
      source =  "hashicorp/google"
      version = "~> 3.69.0"
    }
    k8s = {
      version = ">= 0.9.1"
      source  = "banzaicloud/k8s"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.2.0"
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
