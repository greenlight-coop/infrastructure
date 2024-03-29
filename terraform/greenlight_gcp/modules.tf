module "google_project" {
  source = "../modules/google_project"

  region              = var.region
  zone                = var.zone
  project_id          = local.project_id
  project_name        = local.project_name
  cluster_name        = local.cluster_name
  domain_name         = local.domain_name
}

resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    command = module.google_project.kubeconfig_command
  }
}

module "argo_cd" {
  source = "../modules/argo_cd"

  admin_password  = local.admin_password
  bot_private_key = local.bot_private_key
  domain_name     = local.domain_name
  webhook_secret  = var.webhook_secret

  depends_on = [
    null_resource.update-kubeconfig,
    module.google_project
  ]
}

module "project_cluster" {
  source = "../modules/project_cluster"

  admin_email                 = var.admin_email
  admin_password              = local.admin_password
  base_name                   = local.base_name
  cassandra_datacenter_size   = var.cassandra_datacenter_size
  cassandra_enabled           = var.cassandra_enabled
  cert_manager_enabled        = true
  cert_manager_generate_certs = true
  cluster_provider            = "google"
  destination_server          = local.greenlight_development_cluster_server
  domain_name                 = local.domain_name
  external_dns_enabled        = true
  google_project_id           = local.project_id
  keycloak_instances          = var.keycloak_instances
  metrics_server_enabled      = false
  repo_url                    = local.repo_url
  rook_enabled                = false
  target_revision             = local.target_revision
  use_staging_certs           = var.use_staging_certs

  depends_on = [
    module.google_project,
    module.argo_cd
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  bot_github_token          = var.bot_github_token
  bot_password              = var.bot_password
  bot_private_key           = local.bot_private_key
  cassandra_datacenter_size = var.cassandra_datacenter_size
  cassandra_enabled         = var.cassandra_enabled
  domain_name               = local.domain_name
  repo_url                  = local.repo_url
  rook_enabled              = false
  snyk_token                = var.snyk_token
  target_revision           = local.target_revision
  webhook_secret            = var.webhook_secret

  depends_on = [
    module.google_project,
    module.argo_cd,
    module.project_cluster
  ]
}
