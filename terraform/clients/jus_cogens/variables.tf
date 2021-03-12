variable "admin_email" {
  type    = string
  default = "admin@jus-cogens.com"
}

variable "admin_password" {
  type = string
  default = ""
}

variable "billing_account_id" {
  type    = string
  default = "017EE3-ECBE23-13F65B"
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

variable "existing_project" {
  type = bool
  default = true
}

variable "org_id" {
  type = string
  default = "1061192061015"
}

variable "project_id" {
  type = string
  default = "jus-cogens-prod"
}

variable "project_name" {
  type = string
  default = "jus-cogens-prod"
}

variable "region" {
  type    = string
  default = "us-east4"
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
  length  = 12
  special = false
}

locals {
  admin_password                        = var.admin_password == "" ? random_password.admin.result : var.admin_password
  cluster_name                          = "jus-cogens-prod-cluster"
  cluster_context                       = "gke_${local.project_id}_${var.zone}_${local.cluster_name}"
  domain_name                           = "app.jus-cogens.com"
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
}
