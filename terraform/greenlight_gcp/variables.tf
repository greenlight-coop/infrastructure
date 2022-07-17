variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "admin_password" {
  type      = string
  sensitive = true
  default    = ""
}

variable "bot_github_token" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.bot_github_token) > 0
    error_message = "Value for bot_github_token must be set."
  }
}

variable "bot_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.bot_password) > 0
    error_message = "Value for bot_password must be set."
  }
}

variable "cassandra_enabled" {
  type    = bool
  default = true
}

variable "keycloak_instances" {
  type    = number
}

variable "region" {
  type    = string
  default = "us-east4"
}

variable "snyk_token" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.snyk_token) > 0
    error_message = "Value for snyk_token must be set."
  }
}

variable "use_staging_certs" {
  type    = bool
  default = false
}

variable "webhook_secret" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.webhook_secret) > 0
    error_message = "Value for webhook_secret must be set."
  }
}

variable "zone" {
  type    = string
  default = "us-east4-a"
}

resource "random_password" "admin" {
  length  = 16
  special = false
}

locals {
  admin_password                        = var.admin_password == "" ? random_password.admin.result : var.admin_password
  base_name                             = "greenlight"
  bot_private_key_file                  = "../.ssh/id_ed25519"
  bot_private_key                       = file(local.bot_private_key_file)
  cluster_name                          = "greenlight-development-cluster"
  cluster_context                       = "gke_${local.project_id}_${var.zone}_${local.cluster_name}"
  domain_name                           = "app${local.subdomain_suffix}.greenlightcoop.dev"
  greenlight_development_cluster_server = "https://kubernetes.default.svc"
  project_id                            = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-feature-current"
  project_name                          = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-${terraform.workspace}"
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  subdomain_suffix                      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  target_revision                       = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
