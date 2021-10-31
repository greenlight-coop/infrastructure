resource "kubernetes_secret" "linode-token" {
  metadata {
    name = "linode-token"
    namespace = "default"
  }

  data = {
    token = var.linode_token
  }
}