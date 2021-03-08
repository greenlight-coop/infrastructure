output "project_id" {
  value = local.project_id
}

output "cluster_endpoint" {
  value = module.google_project.cluster_endpoint
}

output "name_servers" {
  value = module.google_project.name_servers
}

output "cluster_ca_certificate" {
  value = module.google_project.cluster_ca_certificate
  sensitive = true
}
