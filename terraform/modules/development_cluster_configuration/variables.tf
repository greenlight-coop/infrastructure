variable "admin_password" {
  type      = string
  sensitive = true
}

# variable "admin_email" {
#   type    = string
# }

# variable "webhook_secret" {
#   type      = string
#   default   = ""
#   sensitive = true
# }

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

# variable "bot_password" {
#   type      = string
#   sensitive = true
#   validation {
#     condition     = length(var.bot_password) > 0
#     error_message = "Value for bot_password must be set."
#   }
# }

# variable "bot_github_token" {
#   type      = string
#   sensitive = true
#   validation {
#     condition     = length(var.bot_github_token) > 0
#     error_message = "Value for bot_github_token must be set."
#   }
# }

# variable "project_id" {
#   type = string
# }

# variable "workspace_suffix" {
#   type = string
# }

# variable "apps_domain_name" {
#   type = string
# }