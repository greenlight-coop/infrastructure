resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [
    digitalocean_kubernetes_cluster.greenlight-development-cluster
  ]
}