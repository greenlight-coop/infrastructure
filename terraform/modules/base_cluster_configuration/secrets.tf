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
