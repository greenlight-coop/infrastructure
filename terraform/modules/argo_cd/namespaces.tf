resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
  }
}