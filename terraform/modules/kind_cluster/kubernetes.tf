resource "local_file" "kind-config" {
    content  = templatefile("${path.module}/manifests/templates/kind-config.yaml", {
      http_port       = var.http_port,
      https_port      = var.https_port,
      http_node_port  = local.http_node_port,
      https_node_port = local.https_node_port,
    })
    filename = "${path.module}/manifests/generated/${var.cluster_name}-kind-config.yaml"
}

resource "null_resource" "kind" {
  provisioner "local-exec" {
    command = "kind create cluster --name ${var.cluster_name} --config ${path.module}/manifests/generated/${var.cluster_name}-kind-config.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name greenlight"
  }

  depends_on = [
    local_file.kind-config
  ]
}
