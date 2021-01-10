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

variable "kind_tls_crt" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.kind_tls_crt) > 0
    error_message = "Value for kind_tls_crt must be set."
  }
}

variable "kind_tls_key" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.kind_tls_key) > 0
    error_message = "Value for kind_tls_key must be set."
  }
}
