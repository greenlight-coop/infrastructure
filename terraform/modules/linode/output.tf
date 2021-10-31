output "kubeconfig" {
  value = base64decode(linode_lke_cluster.greenlight-development-cluster.kubeconfig)
  sensitive = true
}