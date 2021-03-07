terraform {
  required_version = ">= 0.14.7"

  required_providers {
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
      echo var.cluster_endpoint:       ${var.cluster_endpoint} && \
      echo var.cluster_ca_certificate: ${var.cluster_ca_certificate}
    EOF
  }
}
