resource "null_resource" "kubeconfig_get_output" {
  provisioner "local-exec" {
    command = "cat <<EOT > ~/.kube/${local.kubeconfig_output_filename} ${module.linode.kubeconfig}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.kube/${local.kubeconfig_output_filename}"
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "ln -s ~/.kube/${local.kubeconfig_output_filename} ~/.kube/config"
  }

  depends_on = [
    null_resource.kubeconfig_get_output
  ]
}

