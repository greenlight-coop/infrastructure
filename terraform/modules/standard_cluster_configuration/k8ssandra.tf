resource "helm_release" "k8ssandra" {
  name       = "k8ssandra"
  repository = "https://helm.k8ssandra.io/"
  chart      = "k8ssandra"
  version    = "1.0.0"

  values = [
    templatefile(
      "k8ssandra.yaml",
      {
        admin_password = local.admin_password
      }
    )
  ]
}