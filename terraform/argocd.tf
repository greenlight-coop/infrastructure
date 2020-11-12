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

resource "kubernetes_namespace" "greenlight-pipelines" {
  metadata {
    name = "greenlight-pipelines"
  }
}

resource "k8s_manifest" "greenlight-pipelines-git-auth-secret" {
  content = templatefile("manifests/greenlight-pipelines-git-auth-secret.yaml", {
    bot_github_token  = var.bot_github_token
  })
  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}