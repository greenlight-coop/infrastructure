terraform {
  required_version = ">= 0.14.7"
}

resource "null_resource" "print-configuration" {
  provisioner "local-exec" {
    command = <<EOF
      echo var.existing_project:    ${var.existing_project} && \
      echo var.project_name:        ${var.project_name} && \
      echo var.project_id:          ${var.project_id} && \
      echo var.org_id:              ${var.org_id} && \
      echo var.billing_account_id:  ${var.billing_account_id} && \
      echo var.cluster_name:        ${var.cluster_name}
    EOF
  }
}
