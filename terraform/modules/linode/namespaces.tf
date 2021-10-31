resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [
    linode_lke_cluster.greenlight-development-cluster
  ]
}