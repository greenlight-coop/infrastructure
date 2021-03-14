resource "kubernetes_secret" "client-server" {
  provider = kubernetes.greenlight

  metadata {
    name = "${local.client_name}-server"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    name = local.client_name
    server = "https://${module.google_project.cluster_endpoint}"
    config = templatefile("${path.module}/server-config.json", {
      token       = var.domain_name,
      certificate = var.webhook_secret
    })
  }
}
