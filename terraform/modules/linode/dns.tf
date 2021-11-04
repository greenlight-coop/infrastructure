resource "linode_domain" "app_domain" {
    type = "master"
    domain = var.domain_name
    soa_email = var.admin_email
    tags = []
    ttl_sec = var.ttl_sec
}