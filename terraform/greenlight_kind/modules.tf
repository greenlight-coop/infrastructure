module "kind_cluster" {
  source = "../modules/kind_cluster"

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
