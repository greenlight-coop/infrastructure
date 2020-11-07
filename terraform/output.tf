output "development_project_id" {
  value = google_project.development.project_id
}

output "network_project_id" {
  value = google_project.network.project_id
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
  value = "gcloud container clusters get-credentials ${google_container_cluster.development.name} --project ${google_project.development.project_id} --zone ${var.zone}"
}

output "ingress_name_servers" {
  value = "google_dns_managed_zone.ingress.name_servers"
}

output "knative_name_servers" {
  value = "google_dns_managed_zone.knative.name_servers"
}