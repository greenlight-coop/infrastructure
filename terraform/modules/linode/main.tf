terraform {
  required_version = ">= 1.1.6"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.25.2"
    }
  }
}