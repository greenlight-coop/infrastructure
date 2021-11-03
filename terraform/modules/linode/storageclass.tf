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

resource "null_resource" "kubeconfig_get_output" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl patch storageclass linode-block-storage-retain -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' && \
      kubectl patch storageclass linode-block-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    EOT
  }

  depends_on = [
    linode_lke_cluster.greenlight-development-cluster
  ]
}
