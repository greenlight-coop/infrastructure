terraform {
  required_version = ">= 1.0.11"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.15.0"
    }
  }
}