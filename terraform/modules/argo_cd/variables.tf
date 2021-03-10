variable "admin_password" {
  type      = string
  sensitive = true
}

variable "webhook_secret" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type = string
}

locals {
  admin_password_hash           = bcrypt(var.admin_password)
  admin_password_mtime          = timestamp()
  bot_private_key_file          = "${path.module}/.ssh/id_ed25519"
  bot_private_key               = file(local.bot_private_key_file)
}