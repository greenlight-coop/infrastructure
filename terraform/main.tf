provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("account.json")
}

terraform {
  backend "gcs" {
    bucket      = "tf-state-greenlight-development"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}

resource "google_storage_bucket" "state" {
  name          = var.state_bucket
  location      = var.region
  project       = var.project_id
  versioning    {
    enabled = "true"
  }
  storage_class = "NEARLINE"
  labels        = {
    environment = "development"
    created-by  = "terraform"
  }
}
