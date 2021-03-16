resource "kubernetes_namespace" "knative-serving" {
  provider = kubernetes.target
  metadata {
    name = "knative-serving"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}
