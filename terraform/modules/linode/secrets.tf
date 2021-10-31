resource "kubernetes_secret" "linode-token-default" {
  metadata {
    name = "linode-token"
    namespace = "default"
  }

  data = {
    token = var.linode_token
  }
}

resource "kubernetes_secret" "linode-token-istio-letsencrypt" {
  metadata {
    name = "linode-token"
    namespace = "istio-system"
  }

  data = {
    token = var.linode_token
  }

  depends_on = [
    kubernetes_namespace.istio-system
  ]
}
