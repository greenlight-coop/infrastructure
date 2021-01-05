# Equivalent to: 
#   helm upgrade --install argocd argo/argo-cd --version 2.9.5 --namespace argocd --values helm/argocd-values.yaml --wait
# 
# After reaching the UI the first time you can login with username: admin and the password will be the
# name of the server pod. You can get the pod name by running:
# 
# kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
# resource "helm_release" "argo-cd" {
#   name        = "argo-cd"
#   repository  = "https://argoproj.github.io/argo-helm"
#   chart       = "argo-cd"
#   version     = "2.9.5"
#   namespace   = "argocd"

#   values = [ <<-EOT
#     installCRDs: false
#     server:
#       extraArgs:
#       - --insecure
#   EOT
#   ]

#   depends_on = [
#     kubernetes_secret.argocd-github-ssh-key-secret,
#     kubernetes_namespace.argocd
#   ]
# }

resource "local_file" "argocd_kustomization_manifests" {
    for_each = fileset("manifests/argocd/install_templates", "*.yaml")
    content     = "foo!"
    filename = "${path.module}/foo.bar"
}

resource "kustomization_resource" "argocd" {
  provider = kustomization
  manifest = "manifests/argocd/install"
  depends_on = [
    helm_release.argo-cd
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
    google_project_iam_binding.project-iam-binding-dns-admin,
    google_service_account_iam_binding.dns-admin-iam-binding-workload-identity,
  ]
  timeouts {
    delete = "20m"
  }
}
