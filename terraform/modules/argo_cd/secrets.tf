resource "kubernetes_secret" "argocd-github-ssh-key-secret" {
  metadata {
    name = "argoproj-ssh-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    url = "git@github.com"
    sshPrivateKey = <<SSH
${var.bot_private_key}
    SSH
  }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}