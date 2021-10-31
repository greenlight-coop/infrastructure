#!/usr/bin/env bash

set -x

terraform state rm module.project_cluster.module.base_cluster_configuration.k8s_manifest.base-application
terraform state rm module.project_cluster.module.base_cluster_configuration.k8s_manifest.argocd-project
terraform state rm module.argo_cd.null_resource.argocd
terraform state rm module.argo_cd.kubernetes_namespace.argocd
terraform destroy -auto-approve