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

variable "existing_project" {
  type = bool
  default = false
}

variable "project_id" {
  type = string
  default = ""
}

variable "project_name" {
  type = string
  default = ""
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
  default = "e2-medium"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "billing_account_id" {
  type    = string
  default = "01614C-82BAE7-678369"
}

# List available versions:  gcloud container get-server-config --zone us-east4-a
variable "k8s_version" {
  type = string
  default = "1.18.12-gke.1206"
}

variable "admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "webhook_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "use_staging_certs" {
  type    = bool
  default = false
}

variable "bot_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.bot_password) > 0
    error_message = "Value for bot_password must be set."
  }
}

variable "bot_github_token" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.bot_github_token) > 0
    error_message = "Value for bot_github_token must be set."
  }
}
