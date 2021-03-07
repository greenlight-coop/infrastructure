terraform {
  required_version = ">= 0.14.7"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.58.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "google" {
  region      = var.region
}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
    echo var.existing_project: ${var.existing_project} && \
      echo var.project_name: ${var.project_name}
    EOF
  }
}

resource "google_project" "project" {
  count           = var.existing_project ? 0 : 1
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account_id
}
