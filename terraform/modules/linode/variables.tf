variable "cluster_name" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "g6-standard-2"
}

variable "max_node_count" {
  type    = number
  default = 10
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "region" {
  type    = string
}

variable "k8s_version" {
  type = string
  default = "1.21"
}

variable "domain_name" {
  type = string
}
