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
  tls_cert_issuer = var.use_staging_certs ? "letsencrypt-staging" : "letsencrypt-production"
  tls_secret_name = var.use_staging_certs ? "letsencrypt-staging" : "letsencrypt-production" 
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
  depends_on = [
    google_container_cluster.development
  ]
}

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

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "k8s_manifest" "argocd-github-ssh-key-secret" {
  content = templatefile("manifests/argocd-github-ssh-key-secret.yaml", {
    bot_private_key = local.bot_private_key
  })
  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "k8s_manifest" "default-admin-password-secret" {
  content = templatefile("manifests/admin-password-secret.yaml", {
    namespace       = "default"
    admin_password  = local.admin_password
  })
}

resource "k8s_manifest" "grafana-datasources-secret" {
  content = templatefile("manifests/grafana-datasources-secret.yaml", {
    namespace = "default"
  })
}

# Equivalent to: 
#   helm upgrade --install argocd argo/argo-cd --version 2.9.5 --namespace argocd --values helm/argocd-values.yaml --wait
# 
# After reaching the UI the first time you can login with username: admin and the password will be the
# name of the server pod. You can get the pod name by running:
# 
# kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
resource "helm_release" "argo-cd" {
  name        = "argo-cd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = "2.9.5"
  namespace   = "argocd"

  values = [ <<-EOT
    installCRDs: false
    server:
      config:
        url: https://argocd.${local.apps_domain_name}
        repositories: |
          - url: git@github.com:greenlight-coop/argocd-apps.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
      ingress:
        enabled: true
        hosts:
          - argocd.${local.apps_domain_name}
        annotations:
          kubernetes.io/ingress.class: nginx
          cert-manager.io/cluster-issuer: ${local.tls_cert_issuer}
          kubernetes.io/tls-acme: "true"
          nginx.ingress.kubernetes.io/ssl-passthrough: "true"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
        tls:
          - secretName: ${local.tls_secret_name}
            hosts:
              - argocd.${local.apps_domain_name}
        https: true
    configs:
      secret:
        githubSecret: ${local.webhook_secret}
        argocdServerAdminPassword: ${local.admin_password_hash}
        argocdServerAdminPasswordMtime: ${local.admin_password_mtime}
  EOT
  ]

  depends_on = [
    k8s_manifest.letsencrypt-staging-issuer,
    k8s_manifest.letsencrypt-production-issuer,
    k8s_manifest.argocd-github-ssh-key-secret,
    k8s_manifest.grafana-datasources-secret,
    kubernetes_namespace.argocd,
    google_dns_record_set.wildcard-apps-greenlightcoop-dev-cname-record
  ]
}

resource "k8s_manifest" "argocd-project" {
  content = templatefile("manifests/argocd-project.yaml", {})
  depends_on = [
    helm_release.argo-cd
  ]
}

resource "k8s_manifest" "argocd-apps-application" {
  content = templatefile(
    "manifests/argocd-apps-application.yaml", 
    {
      target_revision   = local.argocd_source_target_revision
      tls_cert_issuer   = local.tls_cert_issuer
      tls_secret_name   = local.tls_secret_name
      workspace_suffix  = local.workspace_suffix
    }
  )
  depends_on = [
    k8s_manifest.argocd-project,
    k8s_manifest.default-admin-password-secret,
    google_dns_record_set.wildcard-apps-greenlightcoop-dev-cname-record
  ]
}

resource "k8s_manifest" "knative-serving-crds" {
  content = file("manifests/knative-serving-crds.yaml")
  depends_on = [
    k8s_manifest.argocd-apps-application
  ]
}

resource "null_resource" "knative-serving-crds-twice" {
  provisioner "local-exec" {
    command = "kubectl apply --filename manifests/knative-serving-crds.yaml"
  }
  depends_on = [
    k8s_manifest.knative-serving-crds
  ]
}

resource "k8s_manifest" "knative-serving-core" {
  content = file("manifests/knative-serving-core.yaml")
  depends_on = [
    null_resource.knative-serving-crds-twice
  ]
}

resource "null_resource" "istioctl-install" {
  provisioner "local-exec" {
    command = "istioctl install --skip-confirmation"
  }
  depends_on = [
    k8s_manifest.knative-serving-core,
  ]
}

resource "null_resource" "istio-minimal-operator" {
  provisioner "local-exec" {
    command = "istioctl manifest install -f manifests/istio-minimal-operator.yaml"
  }
  depends_on = [
    null_resource.istioctl-install
  ]
}

data "kubernetes_service" "istio-ingressgateway" {
  metadata {
    namespace = "istio-system"
    name      = "istio-ingressgateway"
  }
  depends_on = [
    null_resource.istio-minimal-operator
  ]
}

resource "null_resource" "enable-serving-istio-injection" {
  provisioner "local-exec" {
    command = "kubectl label namespace knative-serving istio-injection=enabled"
  }
  depends_on = [
    null_resource.istio-minimal-operator,
  ]
}

resource "k8s_manifest" "knative-serving-permissive" {
  content = <<-EOT
    apiVersion: "security.istio.io/v1beta1"
    kind: "PeerAuthentication"
    metadata:
      name: "default"
      namespace: "knative-serving"
    spec:
      mtls:
        mode: PERMISSIVE
  EOT
  depends_on = [
    null_resource.enable-serving-istio-injection
  ]
}

resource "k8s_manifest" "knative-serving-istio" {
  content = file("manifests/knative-serving-istio.yaml")
  depends_on = [
    k8s_manifest.knative-serving-permissive
  ]
}

resource "null_resource" "knative-serving-config-domain" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch configmap/config-domain \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"${local.knative_domain_name}":""}}'
    EOT
  }
  depends_on = [
    k8s_manifest.knative-serving-istio,
    k8s_manifest.knative-serving-core,
    google_dns_record_set.wildcard-knative-greenlightcoop-dev-a-record
  ]
}
