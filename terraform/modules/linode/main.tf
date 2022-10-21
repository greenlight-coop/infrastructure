terraform {
  required_version = ">= 1.3.3"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.28.0"
    }
  }
}