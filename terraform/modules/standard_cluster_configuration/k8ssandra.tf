resource "helm_release" "k8ssandra" {
  name       = "k8ssandra"
  repository = "https://helm.k8ssandra.io/"
  chart      = "k8ssandra"
  version    = "1.0.0"

  values = [
    templatefile(
      "${path.module}/k8ssandra.yaml",
      {
        admin_password = var.admin_password
      }
    )
  ]
}