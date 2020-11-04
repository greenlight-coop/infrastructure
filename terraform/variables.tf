variable "region" {
  type    = string
  default = "us-east4"
}

variable "zone" {
  type    = string
  default = "us-east4-a"
}

variable "org_id" {
  type = string
  default = "636256323415"
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 10
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
  default = "1.17.12-gke.1504"
}

variable "enable_dns" {
  type = bool
  default = false
}

variable "enable_dns_named_resources" {
  type = bool
  default = true
}

variable "admin_password" {
  type    = string
  default = ""
}

variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "webhook_secret" {
  type    = string
  default = ""
}
