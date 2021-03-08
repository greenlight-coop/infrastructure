terraform {
  required_version = ">= 0.14.7"

  required_providers {
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

}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
      echo var.config_context:       ${var.config_context}
    EOF
  }
}
