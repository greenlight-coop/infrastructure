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

