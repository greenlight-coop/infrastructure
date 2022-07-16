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
  default = true
}

variable "cert_manager_enabled" {
  type    = bool
}

variable "cert_manager_generate_certs" {
  type    = bool
}

variable "cluster_provider" {
  type    = string
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

variable "istio_jwt_policy" {
  type    = string
  default = "third-party-jwt"
}

variable "istio_http_node_port" {
  type    = number
  default = 0
}

variable "istio_https_node_port" {
  type    = number
  default = 0
}

variable "kafka_enabled" {
  type    = bool
  default = true
}

variable "metrics_server_enabled" {
  type    = bool
}

variable "repo_url" {
  type    = string
}

variable "rook_enabled" {
  type    = bool
}

variable "target_revision" {
  type    = string
}

variable "use_staging_certs" {
  type    = bool
}
