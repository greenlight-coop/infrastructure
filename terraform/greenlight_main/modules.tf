module "google_project" {
  source = "../modules/google_project"

  org_id              = var.org_id
  billing_account_id  = var.billing_account_id
  region              = var.region
  zone                = var.zone
  project_id          = local.project_id
  project_name        = local.project_name
  existing_project    = var.existing_project
  cluster_name        = "greenlight-development-cluster"
  domain_name         = local.domain_name
}

module "standard_cluster_configuration" {
  cluster_endpoint        = module.google_project.cluster_endpoint
  cluster_ca_certificate  = module.google_project.cluster_ca_certificate
}