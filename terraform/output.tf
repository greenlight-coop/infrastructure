output "project_id" {
  value = google_project.main.project_id
}

output "root_name_servers" {
  value = google_dns_managed_zone.root.name_servers
}

output "dev_name_servers" {
  value = google_dns_managed_zone.root.name_servers
}