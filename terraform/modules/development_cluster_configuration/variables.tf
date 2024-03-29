variable "bot_email" {
  type      = string
  sensitive = true
}

variable "bot_github_token" {
  type      = string
  sensitive = true
}

variable "bot_username" {
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

variable "cassandra_datacenter_size" {
  type    = number
}

variable "cassandra_enabled" {
  type    = bool
}

variable "domain_name" {
  type = string
}

variable "repo_url" {
  type    = string
}

variable "rook_enabled" {
  type    = bool
}

variable "snyk_token" {
  type      = string
  sensitive = true
}

variable "target_revision" {
  type    = string
}

variable "webhook_secret" {
  type      = string
  sensitive = true
}
