resource "k8s_manifest" "development-application" {
  content = templatefile(
    "${path.module}/manifests/development-application.yaml", {
      bot_email                 = var.bot_email,
      bot_username              = var.bot_username,
      cassandra_datacenter_size = var.cassandra_datacenter_size,
      cassandra_enabled         = var.cassandra_enabled,
      domain_name               = var.domain_name,
      repo_url                  = var.repo_url,
      rook_enabled              = var.rook_enabled,
      target_revision           = var.target_revision
    }
  )
}