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

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "kubernetes_namespace" "knative-serving" {
  metadata {
    name = "knative-serving"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}