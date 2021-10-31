variable "admin_email" {
  type    = string
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cassandra_enabled" {
  type    = bool
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

variable "region" {
  type    = string
}

variable "use_staging_certs" {
  type    = bool
}

variable "terraform_token" {
  type    = string
  sensitive = true
  validation {
    condition     = length(var.terraform_token) > 0
    error_message = "Value for terraform_token must be set."
  }
}

variable "tfstate_access_key" {
  type    = string
  sensitive = true
  validation {
    condition     = length(var.tfstate_access_key) > 0
    error_message = "Value for tfstate_access_key must be set."
  }

}

variable "tfstate_secret_key" {
  type    = string
  sensitive = true
  validation {
    condition     = length(var.tfstate_secret_key) > 0
    error_message = "Value for tfstate_secret_key must be set."
  }
}

variable "webhook_secret" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.webhook_secret) > 0
    error_message = "Value for webhook_secret must be set."
  }
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
  # cluster_context                       = "gke_${local.project_id}_${var.zone}_${local.cluster_name}"
  domain_name                           = "apps${local.subdomain_suffix}.greenlightcoop.dev"
  # greenlight_development_cluster_server = "https://kubernetes.default.svc"
  # project_id                            = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-feature-current"
  # project_name                          = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-${terraform.workspace}"
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  subdomain_suffix                      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  target_revision                       = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
