#!/usr/bin/env bash

set -x

terraform state rm module.project_cluster.module.base_cluster_configuration.k8s_manifest.base-application
terraform state rm module.project_cluster.module.base_cluster_configuration.k8s_manifest.argocd-project
terraform state rm module.development_cluster_configuration.k8s_manifest.development-application
terraform state rm module.argo_cd.null_resource.argocd
terraform state rm module.argo_cd.kubernetes_namespace.argocd
terraform state rm module.development_cluster_configuration.kubernetes_namespace.greenlight-pipelines
terraform state rm module.digitalocean.kubernetes_namespace.istio-system
terraform state rm module.project_cluster.module.base_cluster_configuration.kubernetes_namespace.knative-serving
terraform state rm module.project_cluster.module.base_cluster_configuration.kubernetes_namespace.k8ssandra-operator
terraform destroy -auto-approve