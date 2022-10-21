terraform {
  required_version = ">= 1.3.3"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.21.0"
    }
  }
}