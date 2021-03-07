terraform {
  required_version = ">= 0.14.7"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.58.0"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${var.cluster_endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = var.cluster_ca_certificate
}

data "google_client_config" "provider" {}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
      echo var.cluster_endpoint:       ${var.cluster_endpoint} && \
      echo var.cluster_ca_certificate: ${var.cluster_ca_certificate}
    EOF
  }
}
