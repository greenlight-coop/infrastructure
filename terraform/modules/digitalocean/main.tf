terraform {
  required_version = ">= 1.2.5"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.21.0"
    }
  }
}