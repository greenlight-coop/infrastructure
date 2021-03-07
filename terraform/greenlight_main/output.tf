output "project_id" {
  value = module.google_project.project_id
}

output "cluster_endpoint" {
  value = module.google_project.cluster_endpoint
}

output "kubeconfig_command" {
  value = module.google_project.kubeconfig_command
}

output "name_servers" {
  value = module.google_project.name_servers
}

output "cluster_ca_certificate" {
  value = module.google_project.cluster_ca_certificate
  sensitive = true
}
