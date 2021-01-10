module "greenlight" {
  source = "../greenlight"

  admin_password    = var.admin_password
  admin_email       = var.admin_email
  webhook_secret    = var.webhook_secret
  use_staging_certs = var.use_staging_certs
  bot_password      = var.bot_password
  bot_github_token  = var.bot_github_token
  is_kind_cluster   = true
  project_id        = ""
  workspace_suffix  = ""

  depends_on = [
    kubernetes_secret.istio-letsencrypt
  ]
}