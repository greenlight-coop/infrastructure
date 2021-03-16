variable "admin_email" {
  type    = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "base_name" {
  type    = string
}

variable "cassandra_enabled" {
  type    = bool
}

variable "cert_manager_enabled" {
  type    = bool
}

variable "destination_server" {
  type    = string
}

variable "domain_name" {
  type    = string
}

variable "external_dns_enabled" {
  type    = bool
}

variable "google_project_id" {
  type    = string
  default = ""
}

variable "metrics_server_enabled" {
  type    = bool
}

variable "repo_url" {
  type    = string
}

variable "target_revision" {
  type    = string
}

variable "use_staging_certs" {
  type    = bool
}
