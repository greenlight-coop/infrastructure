provider "kubernetes" {
    config_path = "./kubeconfig"
}

provider "k8s" {
    config_path = "./kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
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

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig gcloud container clusters get-credentials ${google_container_cluster.development.name} --project ${google_project.development.project_id} --zone ${var.zone}"
  }
  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "helm_release" "ingress-nginx" {
  name        = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "3.7.1"
  depends_on = [
    null_resource.kubeconfig
  ]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    null_resource.kubeconfig
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
    null_resource.kubeconfig
  ]
}

data "template_file" "letsencrypt-staging-issuer" {
  template = file("manifests/letsencrypt-staging-issuer.yaml")
  vars = {
    administration-email = var.administration-email
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
    administration-email = var.administration-email
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
  depends_on = [
    null_resource.kubeconfig
  ]
}

resource "helm_release" "argo-cd" {
  name        = "argo-cd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = "2.9.5"
  namespace   = "argocd"

  set {
    name  = "installCRDs"
    value = "false"
  }

  set {
    name  = "server.ingress.hosts"
    value = "argocd.dev.greenlight.coop"
  }

  depends_on = [
    k8s_manifest.letsencrypt-production-issuer
  ]
}

# resource "null_resource" "argocd" {
#   provisioner "local-exec" {
#     command = "KUBECONFIG=$PWD/kubeconfig kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
#   }
#   depends_on = [
#     null_resource.argocd-namesapce,
#   ]
# }

