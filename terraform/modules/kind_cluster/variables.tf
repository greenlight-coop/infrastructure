variable "cluster_name" {
  type      = string
}

variable "http_port" {
  type      = number
}

variable "https_port" {
  type      = number
}

variable "kind_tls_crt" {
  type      = string
  sensitive = true
}

variable "kind_tls_key" {
  type      = string
  sensitive = true
}

locals {
  http_node_port  = var.http_port + 30000
  https_node_port = var.https_port + 30000
}