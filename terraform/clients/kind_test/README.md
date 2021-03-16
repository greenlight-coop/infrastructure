### Configure kind Cluster

Note: this is a work in progress, known issue currently in creating the client cluster.

Install the kind cluster

    terraform init \
      && terraform apply -auto-approve -target=module.client_kind_cluster.null_resource.kind \
      && terraform apply -auto-approve -target=module.client_kind_cluster
