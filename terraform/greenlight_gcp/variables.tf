variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "admin_password" {
  type = string
  default = ""
}

variable "billing_account_id" {
  type    = string
  default = "01614C-82BAE7-678369"
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
  default = "636256323415"
}

variable "project_id" {
  type = string
  default = ""
}

variable "project_name" {
  type = string
  default = ""
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
  bot_private_key_file                  = "../.ssh/id_ed25519"
  bot_private_key                       = file(local.bot_private_key_file)
  cluster_name                          = "greenlight-development-cluster"
  cluster_context                       = "gke_${local.project_id}_${var.zone}_${local.cluster_name}"
  default_project_id                    = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-feature-current"
  default_project_name                  = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-${terraform.workspace}"
  domain_name                           = "apps${local.subdomain_suffix}.greenlightcoop.dev"
  greenlight_development_cluster_server = "https://kubernetes.default.svc"
  project_id                            = var.project_id == "" ? local.default_project_id : var.project_id
  project_name                          = var.project_name == "" ? local.default_project_name : var.project_name
  repo_url                              = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  subdomain_suffix                      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  target_revision                       = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
