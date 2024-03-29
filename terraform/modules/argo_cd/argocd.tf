resource "local_file" "argocd_kustomization_manifests" {
    for_each = fileset("${path.module}/manifests/argocd/install_templates", "*.yaml")
    content  = templatefile("${path.module}/manifests/argocd/install_templates/${each.key}", {
      bot_private_key       = var.bot_private_key,
      domain_name           = var.domain_name,
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
    kubernetes_namespace.argocd
  ]
}
