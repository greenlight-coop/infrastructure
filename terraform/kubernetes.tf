provider "kubernetes" {

}

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  project_id                  = module.project-factory.project_id
  name                        = var.cluster_name
  kubernetes_version          = var.k8s_version
  regional                    = false
  region                      = var.region
  zones                       = [var.zone]
  network                     = "default"
  subnetwork                  = "default"
  http_load_balancing         = true
  horizontal_pod_autoscaling  = true
  network_policy              = true
  create_service_account      = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.machine_type
      min_count          = var.min_node_count
      max_count          = var.max_node_count
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = var.preemptible
      initial_node_count = var.min_node_count
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

# resource "google_container_cluster" "primary" {
#   name                     = var.cluster_name
#   project                  = module.project-factory.project_id
#   location                 = var.region
#   min_master_version       = var.k8s_version
#   remove_default_node_pool = true
#   initial_node_count       = 1
# }

# resource "google_container_node_pool" "primary_nodes" {
#   name               = var.cluster_name
#   project            = module.project-factory.project_id
#   location           = var.region
#   cluster            = google_container_cluster.primary.name
#   version            = var.k8s_version
#   initial_node_count = var.min_node_count
#   node_config {
#     preemptible  = var.preemptible
#     machine_type = var.machine_type
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
#   autoscaling { 
#     min_node_count = var.min_node_count
#     max_node_count = var.max_node_count
#   }
#   management {
#     auto_upgrade = false
#   }
#   timeouts {
#     create = "15m"
#     update = "1h"
#   }
# }

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
