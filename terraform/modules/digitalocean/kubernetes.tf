resource "linode_lke_cluster" "greenlight-development-cluster" {
  label       = var.cluster_name
  k8s_version = var.k8s_version
  region      = var.region
  tags        = []

  pool {
    type  = var.machine_type
    count = var.min_node_count

    autoscaler {
      min = var.min_node_count
      max = var.max_node_count
    }
  }
}

resource "digitalocean_kubernetes_cluster" "greenlight-development-cluster" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
  }
}