provider "kubernetes" {

}

resource "google_container_cluster" "development" {
  name                     = "greenlight-development-cluster"
  project                  = google_project.development.project_id
  location                 = var.zone
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [
    google_project_service.container-development
  ]
}

resource "google_container_node_pool" "primary_nodes" {
  name               = "primary-node-pool"
  project            = google_project.development.project_id
  location           = var.zone
  cluster            = google_container_cluster.development.name
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
    command = "KUBECONFIG=$PWD/kubeconfig gcloud container clusters get-credentials ${var.cluster_name} --project ${google_project.main.project_id} --zone ${var.zone}"
  }
  depends_on = [
    google_container_cluster.primary,
  ]
}

resource "null_resource" "ingress-nginx" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.40.2/deploy/static/provider/cloud/deploy.yaml"
  }
  depends_on = [
    null_resource.kubeconfig,
  ]
}

resource "null_resource" "cert-manager" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.yaml"
  }
  depends_on = [
    null_resource.kubeconfig,
  ]
}

resource "null_resource" "argocd-namesapce" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig kubectl create namespace argocd"
  }
  depends_on = [
    null_resource.kubeconfig,
  ]
}

resource "null_resource" "argocd" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
  depends_on = [
    null_resource.argocd-namesapce,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig"
  }
}
