# resource "k8s_manifest" "argocd-greenlight-infrastructure-application" {
#   content = templatefile(
#     "${path.module}/manifests/argocd-greenlight-infrastructure-application.yaml", 
#     {
#       target_revision     = local.argocd_source_target_revision
#       use_staging_certs   = var.use_staging_certs
#       admin_email         = var.admin_email
#       workspace_suffix    = var.workspace_suffix
#       apps_domain_name    = var.apps_domain_name
#       google_project_id   = var.project_id
#       is_kind_cluster     = var.is_kind_cluster
#       lightweight         = var.lightweight
#     }
#   )
#   depends_on = [
#     null_resource.argocd,
#     k8s_manifest.argocd-project,
#     kubernetes_secret.grafana-admin-password-secret,
#     kubernetes_secret.greenlight-pipelines-git-auth,
#     kubernetes_secret.greenlight-pipelines-docker-registry-credentials,
#     kubernetes_secret.greenlight-pipelines-bot-github-token,
#     kubernetes_secret.greenlight-pipelines-webhook-secret,
#     kubernetes_secret.greenlight-pipelines-buildkit-client-certs,
#     kubernetes_secret.greenlight-pipelines-buildkit-daemon-certs,
#     kubernetes_namespace.greenlight-pipelines,
#     kubernetes_namespace.knative-serving,
#   ]
#   timeouts {
#     delete = "20m"
#   }
# }
