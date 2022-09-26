variable "admin_email" {
  type    = string
}

variable "cluster_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "k8s_version" {
  type = string
  default = "1.23"
}

variable "linode_token" {
  type    = string
  sensitive = true
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

variable "ttl_sec" {
  type    = number
  default = 86400
}