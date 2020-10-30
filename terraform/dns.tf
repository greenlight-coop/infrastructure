locals {
  dns_enable_count = var.enable_dns == true ? 1 : 0
}


resource "google_project_service" "dns-network" {
  count   = local.dns_enable_count
  project = google_project.network.project_id
  service = "dns.googleapis.com"
}

resource "google_project_service" "dns-development" {
  count   = local.dns_enable_count
  project = google_project.development.project_id
  service = "dns.googleapis.com"
}

resource "google_dns_managed_zone" "root" {
  count       = local.dns_enable_count
  name        = "greenlight-coop-zone"
  dns_name    = "greenlight.com."
  project     = google_project.network.project_id
  description = "DNS for greenlight.coop"
  depends_on  = [google_project_service.dns-network]
}

resource "google_dns_record_set" "public_website_a" {
  count        = local.dns_enable_count
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "A"
  ttl          = 300

  rrdatas = ["68.168.102.9"]
}

resource "google_dns_record_set" "www" {
  count        = local.dns_enable_count
  name         = "www.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "CNAME"
  ttl          = 300

  rrdatas = ["greenlight.com."]
}

resource "google_dns_record_set" "mx" {
  count        = local.dns_enable_count
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "MX"
  ttl          = 300

  rrdatas = [
    "0 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
    "15 5r2no3qthkyojukke5exmz5xtrxwze6osdjunw77xwrs2ohwgpma.mx-verification.google.com.",
  ]
}

resource "google_dns_record_set" "google-site-verification-txt" {
  count        = local.dns_enable_count
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "TXT"
  ttl          = 300

  rrdatas = ["google-site-verification=lDW-ce49Ygc1lgkankOG-pgx3shPmj_Az5i1df7rkw4"]
}

resource "google_dns_record_set" "github-verification-txt" {
  count        = local.dns_enable_count
  name         = "_github-challenge-greenlight-coop.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "TXT"
  ttl          = 300

  rrdatas = ["5effef20f4"]
}

resource "google_dns_managed_zone" "dev" {
  count       = local.dns_enable_count
  name        = "dev-greenlight-coop-zone"
  dns_name    = "dev.greenlight.com."
  project     = google_project.development.project_id
  description = "DNS for dev.greenlight.coop"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "dev_name_servers" {
  count        = local.dns_enable_count
  name         = "dev.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root[0].name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.dev[0].name_servers
}

resource "google_dns_record_set" "greenlight-development-cluster-ingress-a-test" {
  count        = local.dns_enable_count
  name         = "test.dev.greenlight.com."
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev[0].name
  type         = "A"
  ttl          = 300

  rrdatas = ["34.86.70.60"]
}

resource "google_dns_record_set" "greenlight-development-cluster-ingress-a-wildcard" {
  count        = local.dns_enable_count
  name         = "*.dev.greenlight.com."
  project      = google_project.development.project_id
  managed_zone = google_dns_managed_zone.dev[0].name
  type         = "A"
  ttl          = 300

  rrdatas = ["34.86.70.60"]
}
