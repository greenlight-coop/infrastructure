module "greenlight" {
  source = "../greenlight"

  admin_password    = var.admin_password
  admin_email       = var.admin_email
  webhook_secret    = var.webhook_secret
  use_staging_certs = var.use_staging_certs
  bot_password      = var.bot_password
  bot_github_token  = var.bot_github_token
  apps_domain_name  = local.apps_domain_name
  is_kind_cluster   = false
  project_id        = local.project_id
  workspace_suffix  = local.workspace_suffix

  depends_on = [
    google_container_node_pool.development_primary_nodes,
    google_dns_record_set.apps_name_servers,
    google_project_iam_binding.project-iam-binding-dns-admin,
    google_service_account_iam_binding.dns-admin-iam-binding-workload-identity
  ]
}