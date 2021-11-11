resource "k8s_manifest" "argocd-project" {
  content = templatefile(
    "${path.module}/manifests/argocd-project.yaml", {
      base_name = var.base_name
    }
  )
}

resource "k8s_manifest" "base-application" {
  content = templatefile(
    "${path.module}/manifests/base-application.yaml", {
      admin_email             = var.admin_email,
      base_name               = var.base_name,
      cassandra_enabled       = var.cassandra_enabled,
      cert_manager_enabled    = var.cert_manager_enabled,
      destination_server      = var.destination_server,
      domain_name             = var.domain_name,
      external_dns_enabled    = var.external_dns_enabled,
      google_project_id       = var.google_project_id,
      kafka_enabled           = var.kafka_enabled,
      istio_jwt_policy        = var.istio_jwt_policy
      istio_http_node_port    = var.istio_http_node_port
      istio_https_node_port   = var.istio_https_node_port
      metrics_server_enabled  = var.metrics_server_enabled,
      provider                = var.cluster_provider,
      rook_enabled            = var.rook_enabled,
      repo_url                = var.repo_url,
      target_revision         = var.target_revision
      use_staging_certs       = var.use_staging_certs
    }
  )

  depends_on = [
    k8s_manifest.argocd-project
  ]
}
