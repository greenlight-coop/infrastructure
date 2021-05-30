resource "google_project_service" "dns-development" {
  project = var.project_id
  service = "dns.googleapis.com"
}

resource "google_service_account" "dns-admin" {
  project = var.project_id
  account_id   = "dns-admin"
}

resource "google_project_iam_binding" "project-iam-binding-dns-admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  members = [
    "serviceAccount:${google_service_account.dns-admin.email}"
  ]
}

resource "google_service_account_iam_binding" "dns-admin-iam-binding-workload-identity" {
  service_account_id = google_service_account.dns-admin.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]",
    "serviceAccount:${var.project_id}.svc.id.goog[default/external-dns]"
  ]
}

locals {
  domain_name_terminated     = "${var.domain_name}."
  dns_managed_zone_name      = replace(var.domain_name, ".", "-")
}

resource "google_dns_managed_zone" "domain" {
  name        = local.dns_managed_zone_name
  dns_name    = local.domain_name_terminated
  project     = var.project_id
  description = "DNS for ${var.domain_name}"

  depends_on  = [
    google_project_service.dns-development
  ]
}

resource "google_dns_record_set" "cluster_endpoint_a_record" {
  name         = "k8s.${local.domain_name_terminated}"
  project      = var.project_id
  managed_zone = google_dns_managed_zone.domain.name
  type         = "A"
  ttl          = var.dns_ttl

  rrdatas = [google_container_cluster.cluster.endpoint]
}