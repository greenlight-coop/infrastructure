data "google_client_config" "provider" {}

resource "google_project_service" "container-development" {
  project = var.project_id
  service = "container.googleapis.com"

  depends_on = [
    google_project.project
  ]
}

# provider "kubernetes" {
#   load_config_file = false

#   host  = "https://${google_container_cluster.cluster.endpoint}"
#   token = data.google_client_config.provider.access_token
#   cluster_ca_certificate = base64decode(
#     google_container_cluster.development.master_auth[0].cluster_ca_certificate,
#   )
# }

# provider "k8s" {
#   load_config_file = false

#   host  = "https://${google_container_cluster.cluster.endpoint}"
#   token = data.google_client_config.provider.access_token
#   cluster_ca_certificate = base64decode(
#     google_container_cluster.development.master_auth[0].cluster_ca_certificate,
#   )
# }

resource "google_container_cluster" "cluster" {
  name                     = var.cluster_name
  project                  = var.project_id
  location                 = var.zone
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
  depends_on = [
    google_project_service.container-development
  ]
}

resource "google_container_node_pool" "primary_nodes" {
  name               = "primary-node-pool"
  project            = var.project_id
  location           = var.zone
  cluster            = google_container_cluster.cluster.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
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
  depends_on = [
    google_container_cluster.cluster
  ]
}
