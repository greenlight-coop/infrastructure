data "kubernetes_service" "istio-ingressgateway" {
  metadata {
    namespace = "istio-system"
    name      = "istio-ingressgateway"
  }
  depends_on = [
    k8s_manifest.argocd-greenlight-infrastructure-application
  ]
}

