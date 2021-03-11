resource "null_resource" "base-application" {
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f -<<EOF\n${templatefile(
      "${path.module}/manifests/development-application.yaml", {
        domain_name             = var.domain_name,
        repo_url                = var.repo_url,
        target_revision         = var.target_revision
      }
    )}\nEOF"
  }
}
