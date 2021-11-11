resource "digitalocean_kubernetes_cluster" "greenlight-development-cluster" {
  name          = var.cluster_name
  region        = var.region
  version       = var.k8s_version
  ha            = true
  auto_upgrade  = true
  tags = []

  maintenance_policy {
    start_time  = "04:00"
    day         = "sunday"
  }

  node_pool {
    name        = "primary-node-pool"
    size        = var.machine_type
    auto_scale = true
    min_nodes  = var.min_node_count
    max_nodes  = var.max_node_count
    tags = []
    labels = {}
  }
}
