output "project_id" {
  value = var.project_id
}

output "cluster_endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "kubeconfig_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --project ${var.project_id} --zone ${var.zone}"
}

output "name_servers" {
  value = google_dns_managed_zone.domain.name_servers
}

output "cluster_ca_certificate" {
  value = base64decode(google_container_cluster.development.master_auth[0].cluster_ca_certificate)
  sensitive = true
}
