resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}