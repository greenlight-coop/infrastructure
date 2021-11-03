resource "kubernetes_storage_class" "linode-block-storage-retain-waitforfirstconsumer" {
  metadata {
    name = "linode-block-storage-retain-waitforfirstconsumer"
    annotations = {
      "lke.linode.com/caplke-version" = "v1.21.5-001"
    }
  }
  storage_provisioner = "linodebs.csi.linode.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}