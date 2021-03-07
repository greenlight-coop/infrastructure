terraform {
  required_version = ">= 0.14.7"

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

locals {
  workspace_suffix  = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  project_id        = var.project_id == "" ? "gl-dev${local.workspace_suffix}-${local.development_project_id_suffix}" : var.project_id
}