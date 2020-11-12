resource "helm_release" "ingress-nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "3.7.1"
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

data "kubernetes_service" "ingress-nginx-controller" {
  metadata {
    namespace = "default"
    name      = "ingress-nginx-controller"
  }
  depends_on = [
    helm_release.ingress-nginx
  ]
}
