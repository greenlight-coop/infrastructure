resource "linode_domain" "apps_domain" {
    type = "master"
    domain = var.domain_name
    soa_email = var.admin_email
    tags = []
    ttl_sec = local.ttl_sec
}