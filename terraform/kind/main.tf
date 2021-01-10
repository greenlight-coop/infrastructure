terraform {
  required_version = ">= 0.14.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}

locals {
  admin_password                = var.admin_password == "" ? random_password.admin.result : var.admin_password
  admin_password_hash           = bcrypt(local.admin_password)
  admin_password_mtime          = timestamp()
  bot_private_key_file          = "./.ssh/id_ed25519"
  bot_private_key               = file(local.bot_private_key_file)
}

