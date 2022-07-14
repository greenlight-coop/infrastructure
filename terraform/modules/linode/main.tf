terraform {
  required_version = ">= 1.2.5"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.28.0"
    }
  }
}