terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.44.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 1.13.2"
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

module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 9.2"

  name                  = var.project_name
  random_project_id     = "true"
  org_id                = var.org_id
  billing_account       = var.billing_account_id
  credentials_path      = "credentials.json"
  activate_apis         = ["container.googleapis.com", "cloudbilling.googleapis.com"]
  skip_gcloud_download  = "true"
}
