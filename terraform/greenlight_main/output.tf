output "project_id" {
  value = module.greenlight_development_cluster_google_project.project_id
}

output "cluster_endpoint" {
  value = module.greenlight_development_cluster_google_project.cluster_endpoint
}

output "kubeconfig_command" {
  value = module.greenlight_development_cluster_google_project.kubeconfig_command
}

output "name_servers" {
  value = module.greenlight_development_cluster_google_project.name_servers
}
