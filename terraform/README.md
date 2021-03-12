# Green Light Google Cloud Platform

## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

## Deploy Green Light Development Platform

### Preparation

Steps below are temporary and should be used with caution - delete the environment variables after use 
Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)
    export TF_VAR_webhook_secret=(Green Light GitHub webhook HMAC token value)

### Install GCP Project and GKE Cluster

See the README.md in the `greenlight_gcp` directory. Instructions that follow below should be run in the `greenlight_gcp`
subdirectory after configuring the GCP project and GKE cluster.

### Install kind Cluster

See the README.md in the `greenlight_kind` directory. Instructions that follow below should be run in the `greenlight_kind`
subdirectory after configuring the GCP project and GKE cluster.

### Set Up the Green Light Development Cluster

Install Argo CD and wait for all the services and pods to become available.

    terraform apply -auto-approve -target=module.argo_cd \
      && kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s

Install k8ssandra and wait for configuration to complete.

    terraform apply -auto-approve -target=module.k8ssandra \
      && kubectl wait pods/k8ssandra-dc1-default-sts-0 --for=condition=Ready --timeout=600s

Install base cluster configuration resources

    terraform apply -auto-approve -target=module.base_cluster_configuration \
      && kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s \
      && kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s

Install development cluster configuration resources

    terraform apply -auto-approve -target=module.development_cluster_configuration

Concatenated version of the commands above

    terraform apply -auto-approve -target=module.argo_cd \
      && kubectl -n argocd wait deployments -l app.kubernetes.io/part-of=argocd --for=condition=Available --timeout=240s \
      && terraform apply -auto-approve -target=module.k8ssandra \
      && kubectl wait pods/k8ssandra-dc1-default-sts-0 --for=condition=Ready --timeout=600s \
      && terraform apply -auto-approve -target=module.base_cluster_configuration \
      && sleep 120 && kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s \
      && sleep 30 && kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s \
      && terraform apply -auto-approve -target=module.development_cluster_configuration \
      && terraform output admin_password

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

## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment that can then be destroyed after the modifications 
have been vetted and merged to master. This may be done in either a GCP or Kind cluster environment.

* Create a new Terraform workspace, checkout a branch of all repositories based on the current GitHub issue number 
  and push to GitHub. Commands should be run in either the `greenlight_gcp` or `greenlight_kind` subdirectory.

      meta git checkout -b feature/<n>
      meta git push origin --set-upstream feature/<n>
      terraform init
      terraform workspace new feature-<n> 

* Follow the Deploy Green Light Development Platform instructions given earlier in the corresponding environment README.

* Iterate between deploying the resources in the new workspace and making changes to the configuration

* When all changes have been merged to master, dispose of the temporary workspace and apply changes to the 
  default workspace from master

      meta git fetch --all
      meta git checkout master
      meta git pull
      meta git branch -D feature/<n>
      meta git push origin --delete feature/<n>
      terraform workspace select default
      terraform workspace delete -force feature-<n>