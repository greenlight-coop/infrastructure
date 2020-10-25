provider "google" {
  project     = var.project_id
  region      = var.region
}

resource "random_string" "main" {
  length  = 16
  special = false
  upper   = false
}

resource "google_project" "main" {
  name            = var.project_name
  project_id      = var.project_id != "" ? var.project_id : "development-${random_string.main.result}"
  billing_account = var.billing_account_id
}
