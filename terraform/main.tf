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

resource "random_id" "main" {
  byte_length  = 2
}

resource "google_project" "main" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.main.hex}"
  org_id          = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "container" {
  project = google_project.main.project_id
  service = "container.googleapis.com"
}