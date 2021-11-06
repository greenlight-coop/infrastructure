output "cluster_id" {
  value = digitalocean_kubernetes_cluster.greenlight-development-cluster.id
  sensitive = true
}

output "kubernetes_host" {
  value = digitalocean_kubernetes_cluster.greenlight-development-cluster.endpoint
}

output "kubernetes_token" {
  value = digitalocean_kubernetes_cluster.greenlight-development-cluster.kube_config[0].token
  sensitive = true
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(
    digitalocean_kubernetes_cluster.greenlight-development-cluster.kube_config[0].cluster_ca_certificate
  )
  sensitive = true
}
