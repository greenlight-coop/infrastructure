resource "digitalocean_kubernetes_cluster" "greenlight-development-cluster" {
  name          = var.cluster_name
  region        = var.region
  version       = var.k8s_version
  ha            = true
  auto_upgrade  = true

  maintenance_policy {
    start_time  = "04:00"
    day         = "sunday"
  }

  node_pool {
    name       = "base-pool"
    size       = var.machine_type
    auto_scale = false
    min_nodes  = var.min_node_count
  }
}

resource "digitalocean_volume" "ceph_voume" {
  count =                 var.min_node_count

  region                  = var.region
  name                    = "ceph_voume_${count.index}"
  size                    = 50
  initial_filesystem_type = "ext4"
}


resource "digitalocean_volume_attachment" "foobar" {
  count =                 var.min_node_count

  droplet_id = digitalocean_kubernetes_cluster.node_pool.nodes[count.index].greenlight-development-cluster.id
  volume_id  = digitalocean_volume.ceph_voume[count.index].id
}