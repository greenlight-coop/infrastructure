data "google_client_config" "provider" {}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${google_container_cluster.development.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.development.master_auth[0].cluster_ca_certificate,
  )
}

provider "k8s" {
  load_config_file = false

  host  = "https://${google_container_cluster.development.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.development.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host  = "https://${google_container_cluster.development.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.development.master_auth[0].cluster_ca_certificate,
    )
  }
}

locals {
  enable_dns_named_resources_count = var.enable_dns_named_resources == true ? 1 : 0
}

resource "google_container_cluster" "development" {
  name                     = "greenlight-development-cluster"
  project                  = google_project.development.project_id
  location                 = var.zone
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [
    google_project_service.container-development
  ]
}

resource "google_container_node_pool" "development_primary_nodes" {
  name               = "primary-node-pool"
  project            = google_project.development.project_id
  location           = var.zone
  cluster            = google_container_cluster.development.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

resource "helm_release" "ingress-nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "3.7.1"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
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

data "template_file" "letsencrypt-staging-issuer" {
  template = file("manifests/letsencrypt-staging-issuer.yaml")
  vars = {
    administration_email = var.administration_email
  }
}

resource "k8s_manifest" "letsencrypt-staging-issuer" {
  content = data.template_file.letsencrypt-staging-issuer.rendered
  depends_on = [
    helm_release.cert-manager
  ]
}

data "template_file" "letsencrypt-production-issuer" {
  template = file("manifests/letsencrypt-production-issuer.yaml")
  vars = {
    administration_email = var.administration_email
  }
}

resource "k8s_manifest" "letsencrypt-production-issuer" {
  content = data.template_file.letsencrypt-production-issuer.rendered
  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Equivalent to:
#   helm upgrade --install argocd argo/argo-cd --version 2.9.5 --namespace argocd --values helm/argocd-values.yaml --wait
# 
# After reaching the UI the first time you can login with username: admin and the password will be the
# name of the server pod. You can get the pod name by running:
# 
# kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
resource "helm_release" "argo-cd" {
  count       = local.enable_dns_named_resources_count
  name        = "argo-cd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = "2.9.5"
  namespace   = "argocd"

  values = [ <<-EOT
    installCRDs: false
    server:
      ingress:
        enabled: true
        hosts:
          - argocd${local.workspace_suffix}.dev.greenlight.coop
        annotations:
          kubernetes.io/ingress.class: nginx
          cert-manager.io/cluster-issuer: letsencrypt-production
          kubernetes.io/tls-acme: "true"
          nginx.ingress.kubernetes.io/ssl-passthrough: "true"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
        tls:
          - secretName: letsencrypt-production
            hosts:
              - argocd${local.workspace_suffix}.dev.greenlight.coop
        https: true
  EOT
  ]

  depends_on = [
    k8s_manifest.letsencrypt-production-issuer,
    kubernetes_namespace.argocd
  ]
}

data "template_file" "argocd-project" {
  template = file("manifests/argocd-project.yaml")
  vars = {}
}

resource "k8s_manifest" "argocd-project" {
  content = data.template_file.argocd-project.rendered
  depends_on = [
    helm_release.argo-cd
  ]
}

data "template_file" "argocd-apps-application" {
  template = file("manifests/argocd-apps-application.yaml")
  vars = {
    target_revision = local.argocd_source_target_revision,
    workspace_suffix = local.workspace_suffix
  }
}

resource "k8s_manifest" "argocd-apps-application" {
  content = data.template_file.argocd-apps-application.rendered
  depends_on = [
    helm_release.argo-cd,
    k8s_manifest.argocd-project
  ]
}
