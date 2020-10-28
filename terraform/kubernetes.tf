provider "kubernetes" {

}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  project                  = module.project-factory.project_id
  location                 = var.zone
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name               = 'primary-node-pool'
  project            = module.project-factory.project_id
  location           = var.zone
  cluster            = google_container_cluster.primary.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

# provider "kubernetes" {
#   load_config_file = false

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

# module "argo_cd" {
#   source = "runoncloud/argocd/kubernetes"

#   namespace       = "argocd"
#   argo_cd_version = "1.7.8"
# }

# resource "null_resource" "kubeconfig" {
#   provisioner "local-exec" {
#     command = "KUBECONFIG=$PWD/kubeconfig gcloud container clusters get-credentials ${var.cluster_name} --project ${google_project.main.project_id} --region ${var.region}"
#   }
#   depends_on = [
#     google_container_cluster.primary,
#   ]
# }

# resource "null_resource" "destroy-kubeconfig" {
#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm -f $PWD/kubeconfig"
#   }
# }
