resource "kubernetes_storage_class" "do-block-storage-waitforfirstconsumer" {
  metadata {
    name = "do-block-storage-waitforfirstconsumer"
    labels = {
      "c3.doks.digitalocean.com/component" = "csi-controller-service"
      "c3.doks.digitalocean.com/plane" = "data"
      "doks.digitalocean.com/managed" = "true"
    }
  }
  storage_provisioner = "dobs.csi.digitalocean.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "null_resource" "remove_storage_class_change_default" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl patch storageclass do-block-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    EOT
  }

  depends_on = [
    digitalocean_kubernetes_cluster.greenlight-development-cluster
  ]
}
