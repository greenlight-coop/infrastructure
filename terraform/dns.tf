resource "google_project_service" "dns-development" {
  project = google_project.development.project_id
  service = "dns.googleapis.com"
}

locals {
  ingress_domain_name = "ingress${local.workspace_suffix}.greenlightcoop.dev."
  knative_domain_name = "knative${local.workspace_suffix}.greenlightcoop.dev."
  apps_domain_name = "apps${local.workspace_suffix}.greenlightcoop.dev."
  api_domain_name = "api${local.workspace_suffix}.greenlightcoop.dev."
}

# Ingress

resource "google_dns_managed_zone" "ingress" {
  name        = "ingress-greenlightcoop-dev-zone"
  dns_name    = local.ingress_domain_name
  project     = google_project.development.project_id
  description = "DNS for ingress${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "ingress_name_servers" {
  name         = local.ingress_domain_name
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.ingress.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.ingress.name_servers
}

resource "google_dns_record_set" "ingress-greenlightcoop-dev-a-record" {
  name         = local.ingress_domain_name
  project      = google_project.development.project_id
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
  name         = "*.${local.ingress_domain_name}"
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_dns_record_set.ingress-greenlightcoop-dev-a-record.rrdatas[0]]
}

# Knative

resource "google_dns_managed_zone" "knative" {
  name        = "knative-greenlightcoop-dev-zone"
  dns_name    = local.knative_domain_name
  project     = google_project.development.project_id
  description = "DNS for knative${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "knative_name_servers" {
  name         = local.knative_domain_name
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.knative.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.knative.name_servers
}

resource "google_dns_record_set" "knative-greenlightcoop-dev-a-record" {
  name         = local.knative_domain_name
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.knative.name
  type         = "A"
  ttl          = 300

  rrdatas = [data.kubernetes_service.istio-ingressgateway.load_balancer_ingress[0].ip]

  depends_on = [
    google_dns_record_set.knative_name_servers,
    data.kubernetes_service.istio-ingressgateway
  ]
}

resource "google_dns_record_set" "wildcard-knative-greenlightcoop-dev-a-record" {
  name         = "*.${local.knative_domain_name}"
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_dns_record_set.knative-greenlightcoop-dev-a-record.rrdatas[0]]
}

# Apps

resource "google_dns_managed_zone" "apps" {
  name        = "apps-greenlightcoop-dev-zone"
  dns_name    = local.apps_domain_name
  project     = google_project.development.project_id
  description = "DNS for apps${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "apps_name_servers" {
  name         = local.apps_domain_name
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.apps.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.apps.name_servers
}

resource "google_dns_record_set" "wildcard-apps-greenlightcoop-dev-cname-record" {
  name         = "*.${local.apps_domain_name}"
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [local.ingress_domain_name]
}

# API

resource "google_dns_managed_zone" "api" {
  name        = "api-greenlightcoop-dev-zone"
  dns_name    = local.api_domain_name
  project     = google_project.development.project_id
  description = "DNS for api${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "api_name_servers" {
  name         = local.api_domain_name
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.api.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.api.name_servers
}

resource "google_dns_record_set" "wildcard-api-greenlightcoop-dev-cname-record" {
  name         = "*.${local.api_domain_name}"
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [local.ingress_domain_name]
}
