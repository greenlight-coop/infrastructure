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
  webhook_secret  = var.webhook_secret
  domain_name     = local.domain_name

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
  metrics_server_enabled  = true
  repo_url                = local.repo_url
  target_revision         = local.target_revision

  depends_on = [
    module.kind_cluster,
    module.argo_cd,
    module.k8ssandra
  ]
}
