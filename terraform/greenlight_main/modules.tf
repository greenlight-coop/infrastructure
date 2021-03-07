module "greenlight_development_cluster_google_project" {
  source = "../modules/gl_cluster_google_project"

  org_id              = var.org_id
  billing_account_id  = var.billing_account_id
  region              = var.region
  zone                = var.zone
  project_id          = local.project_id
  project_name        = var.project_name
  existing_project    = var.existing_project
  cluster_name        = "greenlight-development-cluster"
  domain_name         = local.domain_name
}