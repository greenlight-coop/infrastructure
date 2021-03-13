terraform {
  required_version = ">= 0.14.8"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.58.0"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
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

  backend "gcs" {
    bucket      = "tfstate-jus-cogens"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

provider "google" {
  alias       = client_gcp
  credentials = "credentials.json"
}

provider "google" {
  alias       = greenlight_gcp
  credentials = "../../greenlight_gcp/credentials.json"
}

provider "kubernetes" { 
  alias                   = client_kubernetes
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
