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

module "standard_cluster_configuration" {
  source = "../modules/standard_cluster_configuration"

  providers = {
    kubernetes = kubernetes.greenlight_development_kubernetes
  }

  depends_on = [
    null_resource.update-kubeconfig
  ]
}

module "development_cluster_configuration" {
  source = "../modules/development_cluster_configuration"

  depends_on = [
    null_resource.update-kubeconfig
  ]
}