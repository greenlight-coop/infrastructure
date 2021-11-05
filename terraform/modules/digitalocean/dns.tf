resource "digitalocean_domain" "app_domain" {
  name = var.domain_name
}