module "greenlight" {
  source = "../greenlight"
  depends_on = [
    google_container_node_pool.development_primary_nodes,
    google_dns_record_set.apps_name_servers,
    google_project_iam_binding.project-iam-binding-dns-admin,
    google_service_account_iam_binding.dns-admin-iam-binding-workload-identity
  ]
}