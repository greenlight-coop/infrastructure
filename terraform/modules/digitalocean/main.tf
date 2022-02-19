terraform {
  required_version = ">= 1.1.6"

  required_providers {
    digitalocean = {
      source =  "digitalocean/digitalocean"
      version = "~> 2.17.1"
    }
  }
}