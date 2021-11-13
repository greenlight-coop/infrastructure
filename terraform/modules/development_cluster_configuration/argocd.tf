resource "k8s_manifest" "development-application" {
  content = templatefile(
    "${path.module}/manifests/development-application.yaml", {
      domain_name             = var.domain_name,
      repo_url                = var.repo_url,
      rook_enabled            = var.rook_enabled,
      target_revision         = var.target_revision
    }
  )
}