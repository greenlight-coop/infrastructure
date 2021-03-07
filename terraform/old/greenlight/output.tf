output "admin_password" {
  value     = local.admin_password
  sensitive = true
}

output "webhook_secret" {
  value     = local.webhook_secret
  sensitive = true
}
