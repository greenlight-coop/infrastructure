# resource "null_resource" "kubeconfig_get_output" {
#   provisioner "local-exec" {
#     command = "cat <<EOT > ~/.kube/${local.kubeconfig_output_filename} ${module.linode.kubeconfig}"
#   }
# }

# resource "null_resource" "kubeconfig" {
#   provisioner "local-exec" {
#     command = <<EOT
#       chmod 700 ~/.kube/${local.kubeconfig_output_filename} \
#         && rm -f ~/.kube/config \
#         && ln -s ~/.kube/${local.kubeconfig_output_filename} ~/.kube/config
#     EOT
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = "rm ~/.kube/config"
#   }

#   depends_on = [
#     null_resource.kubeconfig_get_output
#   ]
# }

