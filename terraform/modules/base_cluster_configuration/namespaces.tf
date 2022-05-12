resource "kubernetes_namespace" "knative-serving" {
  metadata {
    name = "knative-serving"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_namespace" "k8ssandra-operator" {
  metadata {
    name = "k8ssandra-operator"
  }
}
