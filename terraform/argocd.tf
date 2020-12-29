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
          - url: git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
          - url: git@github.com:greenlight-coop/greenlight-helm-charts.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
          - url: git@github.com:greenlight-coop/greenlight-stage-template.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
          - url: git@github.com:greenlight-coop/greenlight-stage-test.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
          - url: git@github.com:greenlight-coop/greenlight-stage-staging.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
          - url: git@github.com:greenlight-coop/greenlight-stage-production.git
            type: git
            sshPrivateKeySecret:
              name: github-ssh-key
              key: sshPrivateKey
        resource.customizations: |
          admissionregistration.k8s.io/MutatingWebhookConfiguration:
            ignoreDifferences: |
              jsonPointers:
              - /webhooks/0/clientConfig/caBundle
              - /webhooks/0/failurePolicy
          admissionregistration.k8s.io/ValidatingWebhookConfiguration:
            ignoreDifferences: |
              jsonPointers:
              - /webhooks/0/clientConfig/caBundle
              - /webhooks/0/failurePolicy
          apiextensions.k8s.io/CustomResourceDefinition:
            ignoreDifferences: |
              jsonPointers:
              - /spec/preserveUnknownFields
          v1/ConfigMap:
            ignoreDifferences: |
              namespace: knative-serving
              jsonPointers:
              - /data
          rbac.authorization.k8s.io/ClusterRole:
            ignoreDifferences: |
              namespace: knative-serving-admin
              jsonPointers:
              - /rules
          cert-manager.io/ClusterIssuer:
            health.lua: |
              hs = {}
              if obj.status ~= nil then
                if obj.status.conditions ~= nil then
                  for i, condition in ipairs(obj.status.conditions) do
                    if condition.type == "Ready" and condition.status == "False" then
                      hs.status = "Degraded"
                      hs.message = condition.message
                      return hs
                    end
                    if condition.type == "Ready" and condition.status == "True" then
                      hs.status = "Healthy"
                      hs.message = condition.message
                      return hs
                    end
                  end
                end
              end
              hs.status = "Progressing"
              hs.message = "Initializing issuer"
              return hs
    configs:
      secret:
        githubSecret: ${local.webhook_secret}
        argocdServerAdminPassword: ${local.admin_password_hash}
        argocdServerAdminPasswordMtime: ${local.admin_password_mtime}
  EOT
  ]

  depends_on = [
    kubernetes_secret.argocd-github-ssh-key-secret,
    kubernetes_namespace.argocd
  ]
}

resource "k8s_manifest" "argocd-project" {
  content = templatefile("manifests/argocd-project.yaml", {})
  depends_on = [
    helm_release.argo-cd
  ]
}

resource "k8s_manifest" "argocd-greenlight-infrastructure-application" {
  content = templatefile(
    "manifests/argocd-greenlight-infrastructure-application.yaml", 
    {
      target_revision     = local.argocd_source_target_revision
      use_staging_certs   = var.use_staging_certs
      admin_email         = var.admin_email
      workspace_suffix    = local.workspace_suffix
      apps_domain_name    = local.apps_domain_name
      knative_domain_name = local.knative_domain_name
      google_project_id   = local.project_id
    }
  )
  depends_on = [
    helm_release.argo-cd,
    k8s_manifest.argocd-project,
    kubernetes_secret.grafana-admin-password-secret,
    kubernetes_secret.greenlight-pipelines-git-auth,
    kubernetes_secret.greenlight-pipelines-docker-registry-credentials,
    kubernetes_secret.greenlight-pipelines-bot-github-token,
    kubernetes_secret.greenlight-pipelines-webhook-secret,
    kubernetes_namespace.greenlight-pipelines,
    google_dns_record_set.apps_name_servers,
    google_dns_record_set.knative_name_servers,
    google_project_iam_binding.project-iam-binding-dns-admin,
    google_service_account_iam_binding.dns-admin-iam-binding-workload-identity,
  ]
  timeouts {
    delete = "20m"
  }
}
