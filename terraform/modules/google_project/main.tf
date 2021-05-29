terraform {
  required_version = ">= 0.15.4"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.69.0"
    }
  }
}

data "google_client_config" "current" {}