resource "linode_lke_cluster" "greenlight-development-cluster" {
  label       = var.cluster_name
  k8s_version = var.k8s_version
  region      = var.region

  pool {
    type  = var.machine_type
    count = var.min_node_count

    autoscaler {
      min = var.min_node_count
      max = var.max_node_count
    }
  }
}