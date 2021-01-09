terraform {
  required_version = ">= 0.14.3"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
    k8s = {
      source =  "banzaicloud/k8s"
      version = "~> 0.8.4"
    }
    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.0.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}

resource "random_password" "admin" {
  length  = 12
  special = false
}

resource "random_password" "webhook_secret" {
  length  = 24
  special = false
}

locals {
  # development_project_id_suffix = random_id.project_id_suffix.hex
  # project_id                    = var.project_id == "" ? "gl-dev${local.workspace_suffix}-${local.development_project_id_suffix}" : var.project_id
  project_id                    = ""
  # project_name                  = var.project_name == "" ? "gl-development${local.workspace_suffix}" : var.project_name
  # workspace_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  workspace_suffix              = ""
  argocd_source_target_revision = terraform.workspace == "default" ? "HEAD" : replace(terraform.workspace, "-", "/")
  admin_password                = var.admin_password == "" ? random_password.admin.result : var.admin_password
  admin_password_hash           = bcrypt(local.admin_password)
  admin_password_mtime          = timestamp()
  webhook_secret                = var.webhook_secret == "" ? random_password.webhook_secret.result : var.webhook_secret
  bot_private_key_file          = "./.ssh/id_ed25519"
  bot_private_key               = file(local.bot_private_key_file)
}

