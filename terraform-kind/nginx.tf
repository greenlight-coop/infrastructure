resource "helm_release" "ingress-nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "3.11.0"
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
