terraform {
  required_version = ">= 1.1.3"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 4.6.0"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.1"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
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
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/jus_cogens/state"
    credentials = "../../credentials.json"
  }
}

provider "google" {
  credentials = "../../credentials.json"
}

data "google_client_config" "current" {}

data "google_container_cluster" "greenlight_cluster" {
  name     = local.greenlight_cluster_name
  location = local.greenlight_cluster_location
  project  = local.greenlight_project_id
}

provider "k8s" { 
  host                    = "https://${data.google_container_cluster.greenlight_cluster.endpoint}"
  token                   = data.google_client_config.current.access_token
  cluster_ca_certificate  = base64decode(data.google_container_cluster.greenlight_cluster.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" { 
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
