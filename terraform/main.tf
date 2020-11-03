terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.44.0"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
    k8s = {
      source =  "banzaicloud/k8s"
      version = "~> 0.8.3"
    }
    helm = {
      source =  "hashicorp/helm"
      version = "~> 1.3.2"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.0.0"
    }
  }

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

provider "google" {
  region      = var.region
}

resource "random_id" "main" {
  count       = 2
  byte_length = 2
}

locals {
  network_project_id_suffix     = random_id.main[0].hex
  development_project_id_suffix = random_id.main[1].hex
  disabled                      = 0
  workspace_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  # argocd_source_target_revision = terraform.workspace == "default" ? "HEAD" : "-${terraform.workspace}"
}

resource "google_project" "network" {
  name            = "greenlight-network${local.workspace_suffix}"
  project_id      = "gl-network${local.workspace_suffix}-${local.network_project_id_suffix}"
  org_id          = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project" "development" {
  name            = "greenlight-development${local.workspace_suffix}"
  project_id      = "gl-development${local.workspace_suffix}-${local.development_project_id_suffix}"
  org_id          = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "container-development" {
  project = google_project.development.project_id
  service = "container.googleapis.com"
}
