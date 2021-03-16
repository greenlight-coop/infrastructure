variable "admin_email" {
  type    = string
  default = "admin@jus-cogens.com"
}

variable "admin_password" {
  type = string
  default = ""
}

variable "cassandra_enabled" {
  type    = bool
  default = true
}

variable "existing_project" {
  type = bool
  default = true
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
  admin_password              = var.admin_password == "" ? random_password.admin.result : var.admin_password
  base_name                   = "jus-cogens"
  cluster_name                = "jus-cogens-prod-cluster"
  domain_name                 = "app.jus-cogens.com"
  greenlight_project_id       = "gl-development-feature-current" # Change to main cluster: greenlight-coop-development
  greenlight_cluster_name     = "greenlight-development-cluster"
  greenlight_cluster_location = "us-east4-a"
  project_id                  = "jus-cogens-prod"
  project_name                = "jus-cogens-prod"
  repo_url                    = "git@github.com:greenlight-coop/argocd-greenlight-infrastructure.git"
  target_revision             = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
}
