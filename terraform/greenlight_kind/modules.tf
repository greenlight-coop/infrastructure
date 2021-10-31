module "kind_cluster" {
  source = "../modules/kind_cluster"

  cluster_name  = "greenlight"
  http_port     = 80
  https_port    = 443
  kind_tls_crt  = var.kind_tls_crt
  kind_tls_key  = var.kind_tls_key
}

module "argo_cd" {
  source = "../modules/argo_cd"

  admin_password  = local.admin_password
  bot_private_key = local.bot_private_key
  domain_name     = local.domain_name
  webhook_secret  = var.webhook_secret

  depends_on = [
    module.kind_cluster
  ]
}

module "project_cluster" {
  source = "../modules/project_cluster"

  admin_email             = var.admin_email
  admin_password          = local.admin_password
  base_name               = local.base_name
  cassandra_enabled       = var.cassandra_enabled
  cert_manager_enabled    = false
  cluster_provider        = "kind"
  destination_server      = local.greenlight_development_cluster_server
  domain_name             = local.domain_name
  external_dns_enabled    = false
  kafka_enabled           = var.kafka_enabled
  istio_jwt_policy        = "first-party-jwt"
  istio_http_node_port    = 30080
  istio_https_node_port   = 30443
  metrics_server_enabled  = true
  repo_url                = local.repo_url
  target_revision         = local.target_revision
  use_staging_certs       = false

  depends_on = [
    module.kind_cluster,
    module.argo_cd
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  bot_github_token    = var.bot_github_token
  bot_password        = var.bot_password
  bot_private_key     = local.bot_private_key
  domain_name         = local.domain_name
  repo_url            = local.repo_url
  target_revision     = local.target_revision
  webhook_secret      = var.webhook_secret

  depends_on = [
    module.kind_cluster,
    module.argo_cd,
    module.project_cluster
  ]
}
