resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
    labels = {
      "webhooks.knative.dev/exclude" = "true"
    }
  }
}
