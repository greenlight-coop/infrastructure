module "linode" {
  source = "../modules/linode"

  region              = var.region
  cluster_name        = local.cluster_name
  domain_name         = local.domain_name
}

# resource "null_resource" "create-kubeconfig" {
#   provisioner "local-exec" {
#     command = "cat ${module.linode.kubeconfig)} > ~/.kube/config"
#   }
# }

# module "argo_cd" {
#   source = "../modules/argo_cd"

#   admin_password  = local.admin_password
#   bot_private_key = local.bot_private_key
#   domain_name     = local.domain_name
#   webhook_secret  = var.webhook_secret

#   depends_on = [
#     null_resource.update-kubeconfig,
#     module.google_project
#   ]
# }

# module "project_cluster" {
#   source = "../modules/project_cluster"

#   admin_email             = var.admin_email
#   admin_password          = local.admin_password
#   base_name               = local.base_name
#   cassandra_enabled       = var.cassandra_enabled
#   cert_manager_enabled    = true
#   destination_server      = local.greenlight_development_cluster_server
#   domain_name             = local.domain_name
#   external_dns_enabled    = true
#   google_project_id       = local.project_id
#   metrics_server_enabled  = false
#   repo_url                = local.repo_url
#   target_revision         = local.target_revision
#   use_staging_certs       = var.use_staging_certs

#   depends_on = [
#     module.google_project,
#     module.argo_cd
#   ]
# }

# module "development_cluster_configuration" {
#   source = "../modules/development_cluster_configuration"

#   bot_github_token    = var.bot_github_token
#   bot_password        = var.bot_password
#   bot_private_key     = local.bot_private_key
#   domain_name         = local.domain_name
#   repo_url            = local.repo_url
#   target_revision     = local.target_revision
#   webhook_secret      = var.webhook_secret

#   depends_on = [
#     module.google_project,
#     module.argo_cd,
#     module.project_cluster
#   ]
# }
