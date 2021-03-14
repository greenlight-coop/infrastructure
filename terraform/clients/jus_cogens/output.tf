output "admin_password" {
  value = local.admin_password
  sensitive = true
}

output "cluster_ca_certificate" {
  value = module.google_project.cluster_ca_certificate
  sensitive = true
}

output "cluster_endpoint" {
  value = module.google_project.cluster_endpoint
}

output "dns_zone_name" {
  value = module.google_project.dns_zone_name
}

output "kubeconfig_command" {
  value = module.google_project.kubeconfig_command
}

output "name_servers" {
  value = module.google_project.name_servers
}
