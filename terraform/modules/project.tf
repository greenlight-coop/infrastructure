resource "google_project" "project" {
  count           = var.existing_project ? 0 : 1
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account_id
}
