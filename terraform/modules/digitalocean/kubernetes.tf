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
    name        = "base-pool"
    size        = var.machine_type
    auto_scale  = false
    node_count  = var.min_node_count
    tags = []
    labels = {}
  }
}

resource "digitalocean_volume" "ceph_volume" {
  count =                 var.min_node_count

  region                  = var.region
  name                    = "ceph-volume-${count.index}"
  size                    = 100
  tags = []
}


resource "digitalocean_volume_attachment" "ceph_volume_attachment" {
  count =                 var.min_node_count

  droplet_id = digitalocean_kubernetes_cluster.greenlight-development-cluster.node_pool[0].nodes[count.index].droplet_id
  volume_id  = digitalocean_volume.ceph_volume[count.index].id
}