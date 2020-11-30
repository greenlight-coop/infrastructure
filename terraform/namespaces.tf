resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    null_resource.greenlight-kind
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [
    null_resource.greenlight-kind
  ]
}

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
  }
  depends_on = [
    null_resource.greenlight-kind
  ]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
  depends_on = [
    null_resource.greenlight-kind
  ]
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
  depends_on = [
    null_resource.greenlight-kind
  ]
}