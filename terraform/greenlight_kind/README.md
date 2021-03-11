# Green Light Development Platform - Local kind Cluster Configuration

This configuration is intended for local testing of configuration changes.

## Deploy Green Light Development Platform

### Initial Set Up 

Ensure that current `home` DNS records reflect the current IP address.

Manually generate the Let's Encrypt certificates and private key using the following command:

    sudo certbot -d 'apps-home.greenlightcoop.dev' -d '*.apps-home.greenlightcoop.dev' certonly --manual

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)
    export TF_VAR_webhook_secret=(Green Light GitHub webhook HMAC token value)
    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/privkey.pem)

### Configure kind Cluster

Install the kind cluster

    terraform init \
      && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind_greenlight \
      && terraform apply -auto-approve -target=module.kind_cluster

Install Argo CD and wait for all the services and pods to become available.

    terraform apply -auto-approve -target=module.argo_cd \
      && kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s

Install k8ssandra and wait for configuration to complete.

    terraform apply -auto-approve -target=module.k8ssandra \
      && kubectl wait pods/k8ssandra-dc1-default-sts-0 --for=condition=Ready --timeout=600s

Install base cluster configuration resources

    terraform apply -auto-approve -target=module.base_cluster_configuration \
      && kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s

Install standard cluster configuration resources

    terraform apply -auto-approve -target=module.standard_cluster_configuration \

Install development cluster configuration resources

    terraform apply -auto-approve -target=module.development_cluster_configuration \

Concatenated version of the commands above

    terraform init \
      && terraform apply -auto-approve -target=module.kind_cluster.null_resource.kind_greenlight \
      && terraform apply -auto-approve -target=module.kind_cluster \
      && terraform apply -auto-approve -target=module.argo_cd \
      && kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s \
      && echo terraform apply -auto-approve -target=module.k8ssandra \
      && echo kubectl wait pods/k8ssandra-dc1-default-sts-0 --for=condition=Ready --timeout=600s \
      && terraform apply -auto-approve -target=module.base_cluster_configuration \
      && kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s \
      && terraform apply -auto-approve -target=module.standard_cluster_configuration \
      && terraform apply -auto-approve -target=module.development_cluster_configuration \

  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
      - name: Loki
        type: loki
        access: proxy
        url: http://monitoring-loki:3100
        isDefault: true
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://monitoring-prometheus-server