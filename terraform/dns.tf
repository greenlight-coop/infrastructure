# resource "google_project_service" "dns-development" {
#   project = local.project_id
#   service = "dns.googleapis.com"
# }

# resource "google_service_account" "dns-admin" {
#   project = local.project_id
#   account_id   = "dns-admin"
# }

# resource "google_project_iam_binding" "project-iam-binding-dns-admin" {
#   project = local.project_id
#   role    = "roles/dns.admin"
#   members = [
#     "serviceAccount:${google_service_account.dns-admin.email}"
#   ]
# }

# resource "google_service_account_iam_binding" "dns-admin-iam-binding-workload-identity" {
#   service_account_id = google_service_account.dns-admin.name
#   role               = "roles/iam.workloadIdentityUser"
#   members = [
#     "serviceAccount:${local.project_id}.svc.id.goog[cert-manager/cert-manager]",
#     "serviceAccount:${local.project_id}.svc.id.goog[default/external-dns]"
#   ]
# }

locals {
  apps_domain_name                = "apps-home.greenlightcoop.dev"
#   domain_name_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
#   apps_domain_name                = "apps${local.domain_name_suffix}.greenlightcoop.dev"
#   apps_domain_name_terminated     = "${local.apps_domain_name}."
}

# # Apps

# resource "google_dns_managed_zone" "apps" {
#   name        = "apps-greenlightcoop-dev-zone"
#   dns_name    = local.apps_domain_name_terminated
#   project     = local.project_id
#   description = "DNS for ${local.apps_domain_name}"
#   depends_on  = [google_project_service.dns-development]
# }

# resource "google_dns_record_set" "apps_name_servers" {
#   name         = local.apps_domain_name_terminated
#   project      = local.project_id
#   managed_zone = google_dns_managed_zone.apps.name
#   type         = "NS"
#   ttl          = 300

#   rrdatas = google_dns_managed_zone.apps.name_servers
# }
