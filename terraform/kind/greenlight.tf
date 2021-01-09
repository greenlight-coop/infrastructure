module "greenlight" {
  source = "../greenlight"
  depends_on = [
    kubernetes_secret.istio-letsencrypt
  ]
}