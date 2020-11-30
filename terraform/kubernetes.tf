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
  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name greenlight"
  }
}
