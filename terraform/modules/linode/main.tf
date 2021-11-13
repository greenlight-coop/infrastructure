terraform {
  required_version = ">= 1.0.11"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.24.0"
    }
  }
}