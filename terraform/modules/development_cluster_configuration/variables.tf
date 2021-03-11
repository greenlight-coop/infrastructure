variable "bot_github_token" {
  type      = string
  sensitive = true
}

variable "bot_password" {
  type      = string
  sensitive = true
}

variable "bot_private_key" {
  type      = string
  sensitive = true
}

variable "destination_server" {
  type    = string
}

variable "domain_name" {
  type = string
}

variable "repo_url" {
  type    = string
}

variable "target_revision" {
  type    = string
}

variable "webhook_secret" {
  type      = string
  sensitive = true
}
