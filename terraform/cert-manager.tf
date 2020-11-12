locals {
  tls_cert_issuer = var.use_staging_certs ? "letsencrypt-staging" : "letsencrypt-production"
  tls_secret_name = var.use_staging_certs ? "letsencrypt-staging" : "letsencrypt-production" 
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "helm_release" "cert-manager" {
  name        = "cert-manager"
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  version     = "1.0.4"
  namespace   = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.cert-manager
  ]
}

resource "k8s_manifest" "letsencrypt-staging-issuer" {
  content = templatefile("manifests/letsencrypt-staging-issuer.yaml",
    {
      admin_email = var.admin_email
    }
  )
  depends_on = [
    helm_release.cert-manager
  ]
}

resource "k8s_manifest" "letsencrypt-production-issuer" {
  content = templatefile("manifests/letsencrypt-production-issuer.yaml", 
    {
      admin_email = var.admin_email
    }
  )
  depends_on = [
    helm_release.cert-manager
  ]
}
