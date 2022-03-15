terraform {
  required_version = ">= 1.1.7"

  required_providers {
    linode = {
      source =  "linode/linode"
      version = "~> 1.26.1"
    }
  }
}