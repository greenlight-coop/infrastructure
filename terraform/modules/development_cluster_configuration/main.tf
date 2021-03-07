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

data "google_client_config" "provider" {}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${var.cluster_endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = var.cluster_ca_certificate
}

provider "k8s" {
  load_config_file = false

  host  = "https://${var.cluster_endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = var.cluster_ca_certificate
}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
      echo var.existing_project:    ${var.existing_project} && \
      echo var.project_name:        ${var.project_name} && \
      echo var.project_id:          ${var.project_id} && \
      echo var.org_id:              ${var.org_id} && \
      echo var.billing_account_id:  ${var.billing_account_id} && \
      echo var.cluster_name:        ${var.cluster_name}
    EOF
  }
}
