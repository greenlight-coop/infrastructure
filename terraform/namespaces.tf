resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
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

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }

  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}