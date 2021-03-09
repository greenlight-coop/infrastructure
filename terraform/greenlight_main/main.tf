terraform {
  required_version = ">= 0.14.7"

  required_providers {
    kubernetes = {
      source =  "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.9.0"
    }
    null = {
      source =  "hashicorp/null"
      version = "~> 3.1.0"
    }
    random = {
      source =  "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  backend "gcs" {
    bucket      = "tfstate-greenlight"
    prefix      = "terraform/state"
    credentials = "credentials.json"
  }
}

provider "kubernetes" { 
  config_path = "~/.kube/config"
  config_context = local.cluster_context
}

provider "helm" { 
  kubernetes {
    config_path = "~/.kube/config"
    config_context = local.cluster_context
  }
}

provider "k8s" {
  config_path = "~/.kube/config"
  config_context = local.cluster_context
}

resource "null_resource" "initialize-resources" {
  provisioner "local-exec" {
    command = "echo Initialized GCP project, DNS and cluster"
  }
  depends_on = [
    module.google_project.google_container_cluster,
    module.google_project.google_dns_record_set,
    null_resource.update-kubeconfig
  ]
}
