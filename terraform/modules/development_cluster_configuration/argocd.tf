resource "null_resource" "development-application" {
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f -<<EOF\n${templatefile(
      "${path.module}/manifests/development-application.yaml", {
        destination_server      = var.destination_server,
        domain_name             = var.domain_name,
        repo_url                = var.repo_url,
        target_revision         = var.target_revision
      }
    )}\nEOF"
  }
}
