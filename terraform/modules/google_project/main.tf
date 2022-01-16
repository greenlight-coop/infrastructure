terraform {
  required_version = ">= 1.1.3"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 4.6.0"
    }
  }
}

data "google_client_config" "current" {}