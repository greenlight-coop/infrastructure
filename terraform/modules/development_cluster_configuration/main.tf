terraform {
  required_version = ">= 0.14.7"

  required_providers {
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
  cluster_ca_certificate = base64decode(
    google_container_cluster.development.master_auth[0].cluster_ca_certificate,
  )
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
