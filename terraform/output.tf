output "development_project_id" {
  value = google_project.development.project_id
}

output "network_project_id" {
  value = google_project.network.project_id
}

output "root_name_servers" {
  value = google_dns_managed_zone.root.name_servers
}

output "dev_name_servers" {
  value = google_dns_managed_zone.dev.name_servers
}