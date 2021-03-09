module "google_project" {
  source = "../modules/google_project"

  org_id              = var.org_id
  billing_account_id  = var.billing_account_id
  region              = var.region
  zone                = var.zone
  project_id          = local.project_id
  project_name        = local.project_name
  existing_project    = var.existing_project
  cluster_name        = local.cluster_name
  domain_name         = local.domain_name
}

resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    command = module.google_project.kubeconfig_command
  }
}

resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    when = destroy
    command = "kubectl config delete-context ${module.google_project.config_context}"
  }
}

module "standard_cluster_configuration" {
  source = "../modules/standard_cluster_configuration"

  admin_password  = local.admin_password

  depends_on = [
    null_resource.update-kubeconfig
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  admin_email       = var.admin_email
  admin_password    = local.admin_password
  webhook_secret    = var.webhook_secret
  bot_password      = var.bot_password
  bot_github_token  = var.bot_github_token
  domain_name       = local.domain_name
  project_id        = local.project_id

  depends_on = [
    null_resource.update-kubeconfig,
    module.standard_cluster_configuration
  ]
}