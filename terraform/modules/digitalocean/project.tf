resource "digitalocean_project" "cluster_project" {
  name        = var.project_name
  resources   = [
    digitalocean_domain.app_domain.urn,
    digitalocean_kubernetes_cluster.greenlight-development-cluster
  ]
}