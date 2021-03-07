terraform {
  required_version = ">= 0.14.7"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.58.0"
    }
  }
}

provider "google" {
  region      = var.region
}

resource "random_id" "project_id_suffix" {
  byte_length = 2
}

locals {
  development_project_id_suffix = random_id.project_id_suffix.hex
  project_id                    = var.project_id == "" ? "gl-dev${local.workspace_suffix}-${local.development_project_id_suffix}" : var.project_id
  project_name                  = var.project_name == "" ? "gl-development${local.workspace_suffix}" : var.project_name
  workspace_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}

resource "google_project" "project" {
  count           = var.existing_project ? 0 : 1
  name            = local.project_name
  project_id      = local.project_id
  org_id          = var.org_id
  billing_account = var.billing_account_id
}
