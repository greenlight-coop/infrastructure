variable "bot_github_token" {
  type      = string
  sensitive = true
}

variable "bot_password" {
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

locals {
  bot_private_key_file  = "${path.module}/.ssh/id_ed25519"
  bot_private_key       = file(local.bot_private_key_file)
}