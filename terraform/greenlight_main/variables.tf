variable "org_id" {
  type = string
  default = "636256323415"
}

variable "billing_account_id" {
  type    = string
  default = "01614C-82BAE7-678369"
}

variable "region" {
  type    = string
  default = "us-east4"
}

variable "zone" {
  type    = string
  default = "us-east4-a"
}

variable "existing_project" {
  type = bool
  default = true
}

variable "project_id" {
  type = string
  default = ""
}

variable "project_name" {
  type = string
  default = ""
}

variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "admin_password" {
  type = string
  default = ""
}

resource "random_password" "admin" {
  length  = 12
  special = false
}

locals {
  default_project_id    = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-feature-current"
  default_project_name  = terraform.workspace == "default" ? "greenlight-coop-development" : "gl-development-${terraform.workspace}"
  project_id            = var.project_id == "" ? local.default_project_id : var.project_id
  project_name          = var.project_name == "" ? local.default_project_name : var.project_name
  subdomain_suffix      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  domain_name           = "apps${local.subdomain_suffix}.greenlightcoop.dev"
  cluster_name          = "greenlight-development-cluster"
  cluster_context       = "gke_${local.project_id}_${var.zone}_${local.cluster_name}"
  admin_password        = var.admin_password == "" ? random_password.admin.result : var.admin_password
  admin_password_hash   = bcrypt(local.admin_password)
  admin_password_mtime  = timestamp()
}
