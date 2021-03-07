terraform {
  required_version = ">= 0.14.7"

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

locals {
  default_project_id    = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-feature-current"
  default_project_name  = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-${terraform.workspace}"
  project_id            = var.project_id == "" ? default_project_id : var.project_id
  project_name          = var.project_name == "" ? default_project_name : var.project_name
  subdomain_suffix      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  domain_name           = "apps${local.subdomain_suffix}.greenlightcoop.dev"
}
