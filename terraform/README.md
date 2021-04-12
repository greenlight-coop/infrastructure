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

### Quick Setup

Alternate to running the set up steps that follow manually, invoke the `setup.sh` script in either the `greenlight_gcp` or
`greenlight_kind` directory.

Note that if setting up via `greenlight_gcp` it's important to update the domain NS records while the script is running so 
that DNS configuration works correctly in later steps.

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
      && sleep 120 && kubectl -n istio-system wait deployments/istiod --for=condition=Available --timeout=600s \
      && sleep 30 kubectl wait pods/monitoring-loki-0 --for=condition=Ready --timeout=600s

Install development cluster configuration resources

    terraform apply -auto-approve -target=module.development_cluster_configuration

Check that the default Kafka Knative Eventing broker was created successfully. It may be in a failed state due to being created
prior to full configuration of Eventing resources. If this is the case, delete the project and the broker will be recreated.

### Configure Loki Grafana Datasource

Log in to Grafana. Add a Loki Datasource with URL http://monitoring-loki:3100

### Configure GitHub Webooks

Configure a webhook for the [greenlight-coop GitHub organization](https://github.com/organizations/greenlight-coop/settings/hooks/new)
* Create the new GitHub webhook at the greenlight-coop organization level with the following settings:
    * Payload URL:
        * Main: https://argocd.apps-home.greenlightcoop.dev/api/webhook
        * GCP workspace: https://argocd.apps-feature-nnn.greenlightcoop.dev/api/webhook
        * kind cluster: https://argocd.apps-home.greenlightcoop.dev/api/webhook
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Just the push event

Create Tekton webhooks for repositories as needed. Example for Node.js Knative Service webhook:
* Create new GitHub webhook in the target project
    * Payload URL:
        * Main: https://tekton.apps-home.greenlightcoop.dev/webhook/service-pipeline
        * GCP workspace: https://tekton.apps-feature-nnn.greenlightcoop.dev/webhook/service-pipeline
        * kind cluster: https://tekton.apps-home.greenlightcoop.dev/webhook/service-pipeline
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Send me everything
* Repositories that require .../service-pipeline webhook:
    * helloworld
* Repositories that require .../image-pipeline webhook:
    * greenlight-api-tests
    * greenlight-ui-tests
    * helloworld-ui
    * node-utils
    * serenity-js-runner
    * template-processor
    * worker-ui
* Repositories that require .../test-stage-pipeline webhook:
    * greenlight-stage-test
* Repositories that require .../deploy-stage-pipeline webhook:
    * greenlight-stage-staging
    * greenlight-stage-production

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

## greenlight-root GCP Project

All cross-project GCP resources are configured in the `greenlight-root` project. This project was created manually and includes

* The `tfstate-greenlight` bucket that holds Terraform state for all GCP involved projects
* The `terraform` Service Account used for creation and access for Terraform managed resources.
    * terraform@greenlight-root.iam.gserviceaccount.com
    * Give Owner role access to the `greenlight-root`, `greenlight-coop-development` and all feature and client GCP projects
    * Give Service Account Token Creator role in `greenlight-root`, `greenlight-coop-development` and all feature and client 
      GCP projects in order to allow use in Terraform.
    * Generated a JSON key and saved to the root of `terraform` as `credentials.json`

## Resources

### Keycloak

* Get Keycloak admin password

      export KEYCLOAK_PASSWORD=$(kubectl get secret -n keycloak credential-keycloak -o 'jsonpath={.data.ADMIN_PASSWORD}' | base64 -d)
      echo $KEYCLOAK_PASSWORD

### PostgreSQL Cluster

* Port forward to allow cluster access

      kubectl port-forward greenlight-cluster-1 6432:5432 -n default

* Get postgres user password

      export PGPASSWORD=$(kubectl get secret postgres.greenlight-cluster.credentials.postgresql.acid.zalan.do -o 'jsonpath={.data.password}' | base64 -d)
      export PGSSLMODE=require
      psql -U postgres -h localhost -p 6432
