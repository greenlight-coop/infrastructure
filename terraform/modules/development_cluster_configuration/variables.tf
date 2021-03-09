variable "admin_email" {
  type    = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "webhook_secret" {
  type      = string
  sensitive = true
}

# variable "use_staging_certs" {
#   type    = bool
#   default = false
# }

# variable "is_kind_cluster" {
#   type    = bool
#   default = false
# }

# variable "lightweight" {
#   type    = bool
#   default = false
# }

variable "bot_password" {
  type      = string
  sensitive = true
}

variable "bot_github_token" {
  type      = string
  sensitive = true
}

variable "project_id" {
  type = string
}

# variable "workspace_suffix" {
#   type = string
# }

variable "domain_name" {
  type = string
}

locals {
  argocd_source_target_revision = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
  admin_password_hash           = bcrypt(var.admin_password)
  admin_password_mtime          = timestamp()
  bot_private_key_file          = "./.ssh/id_ed25519"
  bot_private_key               = file(local.bot_private_key_file)
}