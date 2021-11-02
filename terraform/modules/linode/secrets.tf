resource "kubernetes_secret" "linode-token-default" {
  metadata {
    name = "linode-token"
    namespace = "default"
  }

  data = {
    token = var.linode_token
  }
}

resource "kubernetes_secret" "linode-token-cert-manager" {
  metadata {
    name = "linode-token"
    namespace = "cert-manager"
  }

  data = {
    token = var.linode_token
  }

  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}
