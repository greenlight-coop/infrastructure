terraform {
  required_version = ">= 1.1.6"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 4.11.0"
    }
  }
}

data "google_client_config" "current" {}