terraform {
  required_version = ">= 1.0.5"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.82.0"
    }
  }
}

data "google_client_config" "current" {}