resource "null_resource" "kind_greenlight" {
  provisioner "local-exec" {
    command = "kind create cluster --name greenlight --config ${path.module}/manifests/kind-config.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name greenlight"
  }
}
