variable "region" {
  type    = string
  default = "us-east4"
}

variable "project_id" {
  type    = string
  default = "greenlight-development"
}

variable "state_bucket" {
  type    = string
  default = "tf-state-greenlight-development"
}

variable "cluster_name" {
  type    = string
  default = "devops-catalog"
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "billing_account_id" {
  type    = string
  default = "01614C-82BAE7-678369"
}

variable "k8s_version" {
  type = string
}

variable "ingress_nginx" {
  type    = bool
  default = false
}
