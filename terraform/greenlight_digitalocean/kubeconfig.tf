resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "doctl kubernetes cluster kubeconfig save ${module.digitalocean.cluster_id}"
  }
}
