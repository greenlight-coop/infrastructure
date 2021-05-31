module "base_cluster_configuration" {
  source = "../base_cluster_configuration"

  admin_email             = var.admin_email
  admin_password          = var.admin_password
  base_name               = var.base_name
  cassandra_enabled       = var.cassandra_enabled
  cert_manager_enabled    = var.cert_manager_enabled
  destination_server      = var.destination_server
  domain_name             = var.domain_name
  external_dns_enabled    = var.external_dns_enabled
  istio_jwt_policy        = var.istio_jwt_policy
  istio_http_node_port    = var.istio_http_node_port
  istio_https_node_port   = var.istio_https_node_port
  kafka_enabled           = var.kafka_enabled
  google_project_id       = var.google_project_id
  metrics_server_enabled  = var.metrics_server_enabled
  repo_url                = var.repo_url
  target_revision         = var.target_revision
  use_staging_certs       = var.use_staging_certs
}
