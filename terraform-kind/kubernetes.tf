data "google_client_config" "provider" {}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${google_container_cluster.development.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.development.master_auth[0].cluster_ca_certificate,
  )
}

provider "k8s" {
  load_config_file = false

  host  = "https://${google_container_cluster.development.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.development.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host  = "https://${google_container_cluster.development.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.development.master_auth[0].cluster_ca_certificate,
    )
  }
}
