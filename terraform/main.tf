terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source =  "hashicorp/google"
      version = "~> 3.44.0"
    }
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    k8s = {
      source =  "banzaicloud/k8s"
      version = "~> 0.8.3"
    }
    http = {
      source =  "hashicorp/http"
      version = "~> 2.0.0"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.0.0"
    }
  }

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

provider "google" {
  region      = var.region
}

resource "random_id" "main" {
  count       = 2
  byte_length = 2
}

locals {
  network_project_id_suffix = random_id.main[0].hex
  development_project_id_suffix = random_id.main[1].hex
}

resource "google_project" "network" {
  name            = "greenlight-network"
  project_id      = "greenlight-network-${local.network_project_id_suffix}"
  org_id          = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project" "development" {
  name            = "greenlight-development"
  project_id      = "greenlight-development-${local.development_project_id_suffix}"
  org_id          = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "dns-network" {
  project = google_project.network.project_id
  service = "dns.googleapis.com"
}

resource "google_project_service" "container-development" {
  project = google_project.development.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "dns-development" {
  project = google_project.development.project_id
  service = "dns.googleapis.com"
}

resource "google_dns_managed_zone" "root" {
  name        = "greenlight-coop-zone"
  dns_name    = "greenlight.com."
  project     = google_project.network.project_id
  description = "DNS for greenlight.coop"
  depends_on  = [google_project_service.dns-network]
}

resource "google_dns_record_set" "public_website_a" {
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root.name
  type         = "A"
  ttl          = 300

  rrdatas = ["68.168.102.9"]
}

resource "google_dns_record_set" "www" {
  name         = "www.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = ["greenlight.com."]
}

resource "google_dns_record_set" "mx" {
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root.name
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
  name         = "greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root.name
  type         = "TXT"
  ttl          = 300

  rrdatas = ["google-site-verification=lDW-ce49Ygc1lgkankOG-pgx3shPmj_Az5i1df7rkw4"]
}

resource "google_dns_record_set" "github-verification-txt" {
  name         = "_github-challenge-greenlight-coop.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.root.name
  type         = "TXT"
  ttl          = 300

  rrdatas = ["5effef20f4"]
}

resource "google_dns_managed_zone" "dev" {
  name        = "dev-greenlight-coop-zone"
  dns_name    = "dev.greenlight.com."
  project     = google_project.development.project_id
  description = "DNS for dev.greenlight.coop"
  depends_on  = [google_project_service.dns-development]
}

resource "google_dns_record_set" "dev_name_servers" {
  name         = "dev.greenlight.com."
  project      = google_project.network.project_id
  managed_zone = google_dns_managed_zone.dev.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.dev.name_servers
}
