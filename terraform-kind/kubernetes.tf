provider "kubernetes" {
}

provider "k8s" {
}

provider "helm" {
}

resource "null_resource" "greenlight-kind" {
  provisioner "local-exec" {
    command = "kind create cluster --name greenlight --config manifests/kind-config.yaml"
  }
}

resource "null_resource" "destroy-greenlight-kind" {
  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name greenlight"
  }
}
