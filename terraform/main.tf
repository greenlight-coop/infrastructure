provider "google" {
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket      = var.state_bucket
    prefix      = "terraform/state"
  }
}

resource "google_storage_bucket" "state" {
  name          = var.state_bucket
  location      = var.region
  project       = var.project_id
  storage_class = "NEARLINE"
  labels        = {
    environment = "development"
    created-by  = "terraform"
  }
}
