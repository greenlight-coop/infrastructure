resource "local_file" "argocd_kustomization_manifests" {
    for_each = fileset("${path.module}/manifests/argocd/install_templates", "*.yaml")
    content  = templatefile("${path.module}/manifests/argocd/install_templates/${each.key}", {
      apps_domain_name      = var.apps_domain_name,
      webhook_secret        = var.webhook_secret,
      admin_password_hash   = local.admin_password_hash,
      admin_password_mtime  = local.admin_password_mtime,
    })
    filename = "${path.module}/manifests/argocd/install/${each.key}"
}

resource "null_resource" "argocd" {
  provisioner "local-exec" {
    command = "kubectl kustomize ${path.module}/manifests/argocd/install | kubectl apply -n argocd -f -"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl kustomize ${path.module}/manifests/argocd/install | kubectl delete -n argocd -f -"
  }
  depends_on = [
    local_file.argocd_kustomization_manifests,  
    kubernetes_secret.argocd-github-ssh-key-secret,
    kubernetes_namespace.argocd
  ]
}

resource "k8s_manifest" "argocd-project" {
  content = file("${path.module}/manifests/argocd-project.yaml")
  depends_on = [
    null_resource.argocd
  ]
}

resource "k8s_manifest" "argocd-greenlight-infrastructure-application" {
  content = templatefile(
    "${path.module}/manifests/argocd-greenlight-infrastructure-application.yaml", 
    {
      target_revision     = local.argocd_source_target_revision
      use_staging_certs   = var.use_staging_certs
      admin_email         = var.admin_email
      workspace_suffix    = var.workspace_suffix
      apps_domain_name    = var.apps_domain_name
      google_project_id   = var.project_id
      is_kind_cluster     = var.is_kind_cluster
    }
  )
  depends_on = [
    null_resource.argocd,
    k8s_manifest.argocd-project,
    kubernetes_secret.grafana-admin-password-secret,
    kubernetes_secret.greenlight-pipelines-git-auth,
    kubernetes_secret.greenlight-pipelines-docker-registry-credentials,
    kubernetes_secret.greenlight-pipelines-bot-github-token,
    kubernetes_secret.greenlight-pipelines-webhook-secret,
    kubernetes_namespace.greenlight-pipelines,
    kubernetes_namespace.knative-serving,
  ]
  timeouts {
    delete = "20m"
  }
}