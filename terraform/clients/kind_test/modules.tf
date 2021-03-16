module "client_kind_cluster" {
  source = "../../modules/kind_cluster"
  providers = {
    kubernetes = kubernetes.client
  }

  cluster_name  = local.client_name
  http_port     = 8080
  https_port    = 8443
  kind_tls_crt  = var.kind_tls_crt
  kind_tls_key  = var.kind_tls_key
}
