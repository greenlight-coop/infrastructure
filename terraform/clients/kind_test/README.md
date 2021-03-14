### Configure kind Cluster

Install the kind cluster

    terraform init \
      && terraform apply -auto-approve -target=module.client_kind_cluster.null_resource.kind \
      && terraform apply -auto-approve -target=module.client_kind_cluster
