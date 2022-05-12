resource "kubernetes_secret" "admin-user" {
  metadata {
    name = "admin-user"
    namespace = "default"
  }

  data = {
    username = "admin"
    password = var.admin_password
  }
}

resource "kubernetes_secret" "k8ssandra-superuser" {
  metadata {
    name = "k8ssandra-superuser"
    namespace = "k8ssandra-operator"
    annotations = {
      "replicator.v1.mittwald.de/replicate-to-matching" = "greenlightcoop.dev/k8ssandra=enabled"
    }
  }

  data = {
    username = "k8ssandra-superuser"
    password = var.admin_password
  }

  depends_on = [
    kubernetes_namespace.k8ssandra-operator
  ]

}
