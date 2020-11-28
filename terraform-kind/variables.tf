variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 10
}

variable "k8s_version" {
  type = string
  default = "1.17.13-gke.2001"
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

variable "use_staging_certs" {
  type    = bool
  default = false
}

variable "bot_password" {
  type    = string
  
  validation {
    condition     = length(var.bot_password) > 0
    error_message = "Value for bot_password must be set."
  }
}

variable "bot_github_token" {
  type    = string
  
  validation {
    condition     = length(var.bot_github_token) > 0
    error_message = "Value for bot_github_token must be set."
  }
}