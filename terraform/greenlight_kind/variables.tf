variable "admin_email" {
  type    = string
  default = "admin@greenlight.coop"
}

variable "admin_password" {
  type = string
  default = ""
}

variable "webhook_secret" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.webhook_secret) > 0
    error_message = "Value for webhook_secret must be set."
  }
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

resource "random_password" "admin" {
  length  = 12
  special = false
}

locals {
  domain_name           = "apps-home.greenlightcoop.dev"
  admin_password        = var.admin_password == "" ? random_password.admin.result : var.admin_password
}
