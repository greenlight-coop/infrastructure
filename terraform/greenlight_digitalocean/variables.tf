variable "admin_email" {
  type    = string
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = ""
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
}

variable "digitalocean_token" {
  type    = string
  sensitive = true
  validation {
    condition     = length(var.digitalocean_token) > 0
    error_message = "Value for digitalocean_token must be set."
  }
}

variable "k8s_version" {
  type = string
}

variable "machine_type" {
  type    = string
}

variable "max_node_count" {
  type    = number
}

variable "min_node_count" {
  type    = number
}

variable "region" {
  type    = string
}

variable "use_staging_certs" {
  type    = bool
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
  cluster_name                          = terraform.workspace == "default" ? "development-cluster" : "development-cluster-${terraform.workspace}"
  domain_name                           = "app${local.subdomain_suffix}.greenlightcoop.dev"
  greenlight_development_cluster_server = "https://kubernetes.default.svc"
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  subdomain_suffix                      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  target_revision                       = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
