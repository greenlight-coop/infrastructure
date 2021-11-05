output "admin_password" {
  value = local.admin_password
  sensitive = true
}

output "kubeconfig" {
  value = module.linode.kubeconfig
  sensitive = true
}
