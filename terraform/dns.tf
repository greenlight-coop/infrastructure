resource "google_project_service" "dns-development" {
  project = local.project_id
  service = "dns.googleapis.com"
}

locals {
  domain_name_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  ingress_domain_name             = "ingress${local.domain_name_suffix}.greenlightcoop.dev"
  knative_domain_name             = "knative${local.domain_name_suffix}.greenlightcoop.dev"
  apps_domain_name                = "apps${local.domain_name_suffix}.greenlightcoop.dev"
  api_domain_name                 = "api${local.domain_name_suffix}.greenlightcoop.dev"
  ingress_domain_name_terminated  = "${local.ingress_domain_name}."
  knative_domain_name_terminated  = "${local.knative_domain_name}."
  apps_domain_name_terminated     = "${local.apps_domain_name}."
  api_domain_name_terminated      = "${local.api_domain_name}."
}

# Ingress

resource "google_dns_managed_zone" "ingress" {
  name        = "ingress-greenlightcoop-dev-zone"
  dns_name    = local.ingress_domain_name_terminated
  project     = local.project_id
  description = "DNS for ${local.ingress_domain_name}"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "ingress_name_servers" {
  name         = local.ingress_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.ingress.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.ingress.name_servers
}

resource "google_dns_record_set" "ingress-greenlightcoop-dev-a-record" {
  name         = local.ingress_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.ingress.name
  type         = "A"
  ttl          = 300

  rrdatas = [data.kubernetes_service.ingress-nginx-controller.load_balancer_ingress[0].ip]

  depends_on = [
    google_dns_record_set.ingress_name_servers,
    data.kubernetes_service.ingress-nginx-controller
  ]
}

resource "google_dns_record_set" "wildcard-ingress-greenlightcoop-dev-a-record" {
  name         = "*.${local.ingress_domain_name_terminated}"
  project      = local.project_id
  managed_zone = google_dns_managed_zone.ingress.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_dns_record_set.ingress-greenlightcoop-dev-a-record.rrdatas[0]]
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

# resource "google_dns_record_set" "knative-greenlightcoop-dev-a-record" {
#   name         = local.knative_domain_name_terminated
#   project      = local.project_id
#   managed_zone = google_dns_managed_zone.knative.name
#   type         = "A"
#   ttl          = 300

#   rrdatas = [data.kubernetes_service.istio-ingressgateway.load_balancer_ingress[0].ip]

#   depends_on = [
#     google_dns_record_set.knative_name_servers,
#     data.kubernetes_service.istio-ingressgateway
#   ]
# }

resource "google_dns_record_set" "wildcard-knative-greenlightcoop-dev-a-record" {
  name         = "*.${local.knative_domain_name_terminated}"
  project      = local.project_id
  managed_zone = google_dns_managed_zone.knative.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_dns_record_set.knative-greenlightcoop-dev-a-record.rrdatas[0]]
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

resource "google_dns_record_set" "wildcard-apps-greenlightcoop-dev-cname-record" {
  name         = "*.${local.apps_domain_name_terminated}"
  project      = local.project_id
  managed_zone = google_dns_managed_zone.apps.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [local.ingress_domain_name_terminated]
}

# API

resource "google_dns_managed_zone" "api" {
  name        = "api-greenlightcoop-dev-zone"
  dns_name    = local.api_domain_name_terminated
  project     = local.project_id
  description = "DNS for ${local.api_domain_name}"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "api_name_servers" {
  name         = local.api_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.api.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.api.name_servers
}

resource "google_dns_record_set" "api-greenlightcoop-dev-a-record" {
  name         = local.api_domain_name_terminated
  project      = local.project_id
  managed_zone = google_dns_managed_zone.api.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_dns_record_set.ingress-greenlightcoop-dev-a-record.rrdatas[0]]
}

resource "google_dns_record_set" "wildcard-api-greenlightcoop-dev-cname-record" {
  name         = "*.${local.api_domain_name_terminated}"
  project      = local.project_id
  managed_zone = google_dns_managed_zone.api.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [google_dns_record_set.api-greenlightcoop-dev-a-record.name]
}