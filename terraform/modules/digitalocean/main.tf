terraform {
  required_version = ">= 1.0.5"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.22.0"
    }
  }
}