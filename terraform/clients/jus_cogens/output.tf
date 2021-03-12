output "project_id" {
  value = var.project_id
}

output "dns_zone_name" {
  value = module.google_project.dns_zone_name
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

output "admin_password" {
  value = local.admin_password
  sensitive = true
}