resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
  }
}

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
  }
}
