variable "admin_email" {
  type    = string
}

variable "destination_server" {
  type    = string
}

variable "cert_manager_enabled" {
  type    = boolean
}

variable "domain_name" {
  type    = string
}

variable "external_dns_enabled" {
  type    = boolean
}

variable "google_project_id" {
  type    = string
  default = ""
}

variable "metrics_server_enabled" {
  type    = boolean
}

variable "repo_url" {
  type    = string
}

variable "target_revision" {
  type    = string
}

variable "use_staging_certs" {
  type    = boolean
  default = false
}