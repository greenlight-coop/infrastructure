locals {
  domain_name_suffix              = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  ingress_domain_name             = "ingress${local.domain_name_suffix}.greenlightcoop.dev"
  knative_domain_name             = "kn${local.domain_name_suffix}.greenlightcoop.dev"
  apps_domain_name                = "apps${local.domain_name_suffix}.greenlightcoop.dev"
  api_domain_name                 = "api${local.domain_name_suffix}.greenlightcoop.dev"
  ingress_domain_name_terminated  = "${local.ingress_domain_name}."
  knative_domain_name_terminated  = "${local.knative_domain_name}."
  apps_domain_name_terminated     = "${local.apps_domain_name}."
  api_domain_name_terminated      = "${local.api_domain_name}."
}
