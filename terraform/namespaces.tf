resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }

  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}