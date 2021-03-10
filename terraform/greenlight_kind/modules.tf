module "kind_cluster" {
  source = "../modules/kind_cluster"

  domain_name         = local.domain_name
}

module "argo_cd" {
  source = "../modules/argo_cd"

  admin_password    = local.admin_password
  webhook_secret    = var.webhook_secret
  domain_name       = local.domain_name

  depends_on = [
    null_resource.update-kubeconfig,
    module.google_project,
  ]
}
