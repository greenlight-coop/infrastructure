output "development_project_id" {
  value = local.project_id
}

output "admin_password" {
  value = local.admin_password
}

output "webhook_secret" {
  value = local.webhook_secret
}

output "cluster_endpoint" {
  value = google_container_cluster.development.endpoint
}

output "kubeconfig_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.development.name} --project ${local.project_id} --zone ${var.zone}"
}

output "apps_name_servers" {
  value = google_dns_managed_zone.apps.name_servers
}

output "knative_name_servers" {
  value = google_dns_managed_zone.knative.name_servers
}

output "kong_name_servers" {
  value = google_dns_managed_zone.knative.name_servers
}