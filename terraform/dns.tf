resource "google_project_service" "dns-development" {
  project = local.project_id
  service = "dns.googleapis.com"
}

locals {
  domain_name_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  kong_domain_name                = "kong${local.domain_name_suffix}.greenlightcoop.dev"
  knative_domain_name             = "kn${local.domain_name_suffix}.greenlightcoop.dev"
  apps_domain_name                = "apps${local.domain_name_suffix}.greenlightcoop.dev"
  api_domain_name                 = "api${local.domain_name_suffix}.greenlightcoop.dev"
  kong_domain_name_terminated     = "${local.kong_domain_name}."
  knative_domain_name_terminated  = "${local.knative_domain_name}."
  apps_domain_name_terminated     = "${local.apps_domain_name}."
  api_domain_name_terminated      = "${local.api_domain_name}."
}

# Apps

resource "google_dns_managed_zone" "apps" {
  name        = "apps-greenlightcoop-dev-zone"
  dns_name    = local.apps_domain_name_terminated
  project     = local.project_id
  description = "DNS for ${local.apps_domain_name}"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "apps_name_servers" {
  name         = local.apps_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.apps.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.apps.name_servers
}

# Knative

resource "google_dns_managed_zone" "knative" {
  name        = "knative-greenlightcoop-dev-zone"
  dns_name    = local.knative_domain_name_terminated
  project     = local.project_id
  description = "DNS for ${local.knative_domain_name}"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "knative_name_servers" {
  name         = local.knative_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.knative.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.knative.name_servers
}

# Kong

resource "google_dns_managed_zone" "kong" {
  name        = "kong-greenlightcoop-dev-zone"
  dns_name    = local.kong_domain_name_terminated
  project     = local.project_id
  description = "DNS for ${local.kong_domain_name}"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "kong_name_servers" {
  name         = local.kong_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.kong.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.kong.name_servers
}
