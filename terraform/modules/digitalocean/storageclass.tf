resource "null_resource" "remove_storage_class_default" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl patch storageclass do-block-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    EOT
  }

  depends_on = [
    digitalocean_kubernetes_cluster.greenlight-development-cluster
  ]
}
