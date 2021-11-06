resource "kubernetes_secret" "digitalocean_token-default" {
  metadata {
    name = "digitalocean-token"
    namespace = "default"
  }

  data = {
    token = var.digitalocean_token
  }
}

resource "kubernetes_secret" "digitalocean-token-istio-system" {
  metadata {
    name = "digitalocean-token"
    namespace = "istio-system"
  }

  data = {
    token = var.digitalocean_token
  }

  depends_on = [
    kubernetes_namespace.istio-system
  ]
}
