resource "null_resource" "kubeconfig_get_output" {
  provisioner "local-exec" {
    command = "cat <<EOT > ~/.kube/${local.kubeconfig_output_filename} ${module.linode.kubeconfig}"
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "chmod 700 ln -s ~/.kube/${local.kubeconfig_output_filename} && ln -s ~/.kube/${local.kubeconfig_output_filename} ~/.kube/config"
  }

  depends_on = [
    null_resource.kubeconfig_get_output
  ]
}

