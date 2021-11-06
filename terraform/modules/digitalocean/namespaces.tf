resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [
    digitalocean_kubernetes_cluster.greenlight-development-cluster
  ]
}