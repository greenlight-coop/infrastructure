terraform {
  required_version = ">= 0.14.7"

  required_providers {
    random = {
      source =  "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

resource "random_id" "project_id_suffix" {
  byte_length = 2
}

locals {
  development_project_id_suffix = random_id.project_id_suffix.hex
  workspace_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  project_id                    = var.project_id == "" ? "gl-dev${local.workspace_suffix}-${local.development_project_id_suffix}" : var.project_id
  subdomain_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  domain_name                   = "apps${local.domain_name_suffix}.greenlightcoop.dev"
}
