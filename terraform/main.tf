provider "google" {
  project     = var.project_id
  region      = var.region
}

resource "random_string" "main" {
  length  = 16
  special = false
  upper   = false
}

resource "google_project" "main" {
  name            = var.project_name
  project_id      = var.project_id != "" ? var.project_id : "development-${random_string.main.result}"
  billing_account = var.billing_account_id
}

resource "google_project_service" "container" {
  project = google_project.main.project_id
  service = "container.googleapis.com"
}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  project                  = google_project.main.project_id
  location                 = var.region
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [
    google_project_service.container
  ]
}

resource "google_container_node_pool" "primary_nodes" {
  name               = var.cluster_name
  project            = google_project.main.project_id
  location           = var.region
  cluster            = google_container_cluster.primary.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig gcloud container clusters get-credentials ${var.cluster_name} --project ${google_project.main.project_id} --region ${var.region}"
  }
  depends_on = [
    google_container_cluster.primary,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig"
  }
}
