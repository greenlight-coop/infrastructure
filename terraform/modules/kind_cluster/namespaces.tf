resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }

  depends_on = [
    null_resource.kind
  ]
}