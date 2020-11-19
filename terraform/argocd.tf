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
      target_revision     = local.argocd_source_target_revision
      tls_cert_issuer     = local.tls_cert_issuer
      tls_secret_name     = local.tls_secret_name
      workspace_suffix    = local.workspace_suffix
      api_domain_name     = local.api_domain_name
      apps_domain_name    = local.apps_domain_name
      knative_domain_name = local.knative_domain_name
    }
  )
  depends_on = [
    k8s_manifest.argocd-project,
    k8s_manifest.default-admin-password-secret,
    google_dns_record_set.wildcard-apps-greenlightcoop-dev-cname-record,
    google_dns_record_set.wildcard-knative-greenlightcoop-dev-a-record,
    google_dns_record_set.api-greenlightcoop-dev-a-record,
    null_resource.knative-serving-config-network-tls
  ]
}

# greenlight-pipelines configuration

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
  }
}

resource "kubernetes_secret" "greenlight-pipelines-git-auth" {
  metadata {
    name = "git-auth"
    namespace = "greenlight-pipelines"
    annotations = {
      "tekton.dev/git-0" = "github.com"
    }
  }

  data = {
    known_hosts = <<KNOWN_HOSTS
github.com,192.30.253.112 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    KNOWN_HOSTS
    ssh-privatekey = <<DOCKER
${local.bot_private_key}
    DOCKER
  }

  type = "kubernetes.io/ssh-auth"

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-docker-registry-credentials" {
  metadata {
    name = "docker-registry-credentials"
    namespace = "greenlight-pipelines"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "greenlightcoopbot",
          "password": "${var.bot_password}",
          "email": "bot@greenlight.coop",
          "auth": "${base64encode("greenlightcoopbot:${var.bot_password}")}"
        }
      }
    }
    DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-webhook-secret" {
  metadata {
    name = "webhook-secret"
    namespace = "greenlight-pipelines"
  }

  data = {
    webhookSecretValue = local.webhook_secret
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

# Prow configuration

resource "kubernetes_namespace" "prow" {
  metadata {
    name = "prow"
  }
}

resource "kubernetes_namespace" "test-pods" {
  metadata {
    name = "test-pods"
  }
}

resource "kubernetes_secret" "prow-hmac-token" {
  metadata {
    name = "hmac-token"
    namespace = "prow"
  }

  data = {
    hmac = local.webhook_secret
  }

  depends_on = [
    kubernetes_namespace.prow
  ]
}

resource "kubernetes_secret" "prow-github-token" {
  metadata {
    name = "github-token"
    namespace = "prow"
  }

  data = {
    token = var.bot_github_token
  }

  depends_on = [
    kubernetes_namespace.prow
  ]
}

resource "google_service_account" "prow-gcs-publisher" {
  account_id  = "prow-gcs-publisher"
  project     = local.project_id
}

resource "google_storage_bucket" "prow-artifacts" {
  name    = "greenlight-prow-artifacts${local.workspace_suffix}"
  project = local.project_id
}

resource "google_storage_bucket_iam_member" "prow-artifacts--all-users" {
  bucket = google_storage_bucket.prow-artifacts.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "prow-artifacts--prow-gcs-publisher" {
  bucket = google_storage_bucket.prow-artifacts.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.prow-gcs-publisher.email}"
}

resource "google_service_account_key" "prow-gcs-publisher-key" {
  service_account_id = google_service_account.prow-gcs-publisher.name
}

resource "kubernetes_secret" "gcs-credentials" {
  metadata {
    name      = "gcs-credentials"
    namespace = "test-pods"
  }
  data = {
    "service-account.json" = <<DATA
    {
      "type": "service_account",
      "project_id": "${local.project_id}",
      "private_key": "${base64decode(google_service_account_key.prow-gcs-publisher-key.private_key)}"
      "client_email": "${google_service_account.prow-gcs-publisher.email}",
      "client_id": "${google_service_account.prow-gcs-publisher.unique_id}",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/${google_service_account.prow-gcs-publisher.account_id}%40${local.project_id}.iam.gserviceaccount.com"
    }
    DATA
  }

  depends_on = [
    kubernetes_namespace.test-pods
  ]
}