resource "google_project_service" "dns-development" {
  project = google_project.development.project_id
  service = "dns.googleapis.com"
}

locals {
  ingress_domain_name = "ingress${local.workspace_suffix}.greenlightcoop.dev."
  knative_domain_name = "knative${local.workspace_suffix}.greenlightcoop.dev."
}

resource "google_dns_managed_zone" "ingress" {
  name        = "ingress-greenlightcoop-dev-zone"
  dns_name    = local.ingress_domain_name
  project     = google_project.development.project_id
  description = "DNS for ingress${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-network]
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

resource "google_dns_managed_zone" "knative" {
  name        = "knative-greenlightcoop-dev-zone"
  dns_name    = local.knative_domain_name
  project     = google_project.development.project_id
  description = "DNS for knative${local.workspace_suffix}.greenlightcoop.dev"
  depends_on  = [google_project_service.dns-network]
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
