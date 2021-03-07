output "admin_password" {
  value     = module.greenlight.admin_password
  sensitive = true
}

output "webhook_secret" {
  value     = module.greenlight.webhook_secret
  sensitive = true
}
