resource "kubernetes_secret" "argocd-github-ssh-key-secret" {
  metadata {
    name = "github-ssh-key"
    namespace = "argocd"
  }

  data = {
    sshPrivateKey = <<SSH
${var.bot_private_key}
    SSH
  }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
