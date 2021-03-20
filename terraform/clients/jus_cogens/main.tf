terraform {
  required_version = ">= 0.14.8"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.58.0"
    }
    k8s = {
      version = ">= 0.9.0"
      source  = "banzaicloud/k8s"
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
