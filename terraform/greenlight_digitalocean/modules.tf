module "digitalocean" {
  source = "../modules/digitalocean"

  cluster_name        = local.cluster_name
  digitalocean_token  = var.digitalocean_token
  domain_name         = local.domain_name
  k8s_version         = var.k8s_version
  machine_type        = var.machine_type
  max_node_count      = var.max_node_count
  min_node_count      = var.min_node_count
  project_name        = local.project_name
  region              = var.region
}

module "argo_cd" {
  source = "../modules/argo_cd"

  admin_password  = local.admin_password
  bot_private_key = local.bot_private_key
  domain_name     = local.domain_name
  webhook_secret  = var.webhook_secret

  depends_on = [
    null_resource.kubeconfig,
    module.digitalocean
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
  cluster_provider            = "digitalocean"
  destination_server          = local.greenlight_development_cluster_server
  domain_name                 = local.domain_name
  external_dns_enabled        = true
  keycloak_instances          = var.keycloak_instances
  metrics_server_enabled      = true
  repo_url                    = local.repo_url
  rook_enabled                = true
  target_revision             = local.target_revision
  use_staging_certs           = var.use_staging_certs

  depends_on = [
    module.digitalocean,
    module.argo_cd
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  bot_github_token          = var.bot_github_token
  bot_password              = var.bot_password
  bot_private_key           = local.bot_private_key
  bot_username              = var.bot_username
  cassandra_datacenter_size = var.cassandra_datacenter_size
  cassandra_enabled         = var.cassandra_enabled
  domain_name               = local.domain_name
  repo_url                  = local.repo_url
  rook_enabled              = true
  snyk_token                = var.snyk_token
  target_revision           = local.target_revision
  webhook_secret            = var.webhook_secret

  depends_on = [
    module.digitalocean,
    module.argo_cd,
    module.project_cluster
  ]
}
