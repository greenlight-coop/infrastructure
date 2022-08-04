variable "admin_email" {
  type    = string
}

variable "admin_password" {
  type = string
  default = ""
}

variable "cassandra_datacenter_size" {
  type    = number
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

variable "bot_username" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.bot_username) > 0
    error_message = "Value for bot_username must be set."
  }
}

variable "kafka_enabled" {
  type    = bool
  default = false
}

variable "keycloak_instances" {
  type    = number
}

variable "kind_tls_crt" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.kind_tls_crt) > 0
    error_message = "Value for kind_tls_crt must be set."
  }
}

variable "kind_tls_key" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.kind_tls_key) > 0
    error_message = "Value for kind_tls_key must be set."
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

variable "snyk_token" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.snyk_token) > 0
    error_message = "Value for snyk_token must be set."
  }
}

locals {
  admin_password                        = var.admin_password == "" ? random_password.admin.result : var.admin_password
  base_name                             = "greenlight"
  bot_private_key_file                  = "../.ssh/id_ed25519"
  bot_private_key                       = file(local.bot_private_key_file)
  domain_name                           = "app-home.greenlightcoop.dev"
  greenlight_development_cluster_server = "https://kubernetes.default.svc"
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  target_revision                       = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
