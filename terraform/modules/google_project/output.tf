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
  value = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  sensitive = true
}

output "config_context" {
  value = "gke_${var.project_id}_${var.zone}_${var.cluster_name}"
}