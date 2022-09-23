resource "kubernetes_secret" "istio-letsencrypt" {
  metadata {
    name = "istio-letsencrypt"
    namespace = "istio-system"
  }

  data = {
    "tls.crt" = var.tls_crt
    "tls.key" = var.tls_key
  }

  depends_on = [
    kubernetes_namespace.istio-system
  ]
}
