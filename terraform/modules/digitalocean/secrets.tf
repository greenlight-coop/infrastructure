resource "kubernetes_secret" "digitalocean_token-default" {
  metadata {
    name = "digitalocean_token"
    namespace = "default"
  }

  data = {
    token = var.digitalocean_token
  }
}

resource "kubernetes_secret" "digitalocean_token-cert-manager" {
  metadata {
    name = "digitalocean_token"
    namespace = "cert-manager"
  }

  data = {
    token = var.digitalocean_token
  }

  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
