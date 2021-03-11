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

module "k8ssandra" {
  source = "../modules/k8ssandra"

  admin_password  = local.admin_password

  depends_on = [
    module.kind_cluster
  ]
}

module "base_cluster_configuration" {
  source = "../modules/base_cluster_configuration"

  admin_email             = var.admin_email
  cert_manager_enabled    = false
  destination_server      = local.greenlight_development_cluster_server
  domain_name             = local.domain_name
  external_dns_enabled    = false
  istio_jwt_policy        = "first-party-jwt"
  istio_http_node_port    = 30080
  istio_https_node_port   = 30443
  metrics_server_enabled  = true
  repo_url                = local.repo_url
  target_revision         = local.target_revision

  depends_on = [
    module.kind_cluster,
    module.argo_cd
  ]
}

module "standard_cluster_configuration" {
  source = "../modules/standard_cluster_configuration"

  depends_on = [
    module.kind_cluster,
    module.base_cluster_configuration
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  bot_github_token    = var.bot_github_token
  bot_password        = var.bot_password
  bot_private_key     = local.bot_private_key
  destination_server  = local.greenlight_development_cluster_server
  domain_name         = local.domain_name
  repo_url            = local.repo_url
  target_revision     = local.target_revision
  webhook_secret      = var.webhook_secret

  depends_on = [
    module.kind_cluster,
    module.standard_cluster_configuration
  ]
}
