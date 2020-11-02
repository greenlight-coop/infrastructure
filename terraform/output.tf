output "development_project_id" {
  value = google_project.development.project_id
}

output "network_project_id" {
  value = google_project.network.project_id
}

output "cluster_endpoint" {
  value = google_container_cluster.development.endpoint
}

output "kubeconfig_command" {
  value ="gcloud container clusters get-credentials ${google_container_cluster.development.name} --project ${google_project.development.project_id} --zone ${var.zone}"
}