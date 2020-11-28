resource "null_resource" "ingress-nginx" {
  provisioner "local-exec" {
    command = "kubectl apply -f manifests/ingress-nginx-kind-3.12.0.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f manifests/ingress-nginx-kind-3.12.0.yaml"
  }
}

data "kubernetes_service" "ingress-nginx-controller" {
  metadata {
    namespace = "ingress-nginx"
    name      = "ingress-nginx-controller"
  }
  depends_on = [
    null_resource.ingress-nginx
  ]
}
