resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [
    linode_lke_cluster.greenlight-development-cluster
  ]
}