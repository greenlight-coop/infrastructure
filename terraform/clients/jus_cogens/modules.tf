module "google_project" {
  source = "../../modules/google_project"


  region              = var.region
  zone                = var.zone
  project_id          = local.project_id
  project_name        = local.project_name
  cluster_name        = local.cluster_name
  domain_name         = local.domain_name
}

resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    command = module.google_project.kubeconfig_command
  }
}

# module "k8ssandra" {
#   source = "../../modules/k8ssandra"

#   admin_password  = local.admin_password

#   depends_on = [
#     null_resource.update-kubeconfig,
#     module.google_project
#   ]
# }

# module "base_cluster_configuration" {
#   source = "../../modules/base_cluster_configuration"

#   admin_email             = var.admin_email
#   cert_manager_enabled    = true
#   destination_server      = module.google_project.cluster_endpoint
#   domain_name             = local.domain_name
#   external_dns_enabled    = true
#   google_project_id       = var.project_id
#   metrics_server_enabled  = false
#   repo_url                = local.repo_url
#   target_revision         = local.target_revision
#   use_staging_certs       = var.use_staging_certs

#   depends_on = [
#     null_resource.update-kubeconfig,
#     module.google_project,
#     module.k8ssandra
#   ]
# }
