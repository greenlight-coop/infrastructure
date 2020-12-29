# Green Light Google Cloud Platform

## Prepare environment

Global for all instructions that follow

    gcloud auth application-default login
    export GCP_ORGANIZATION_ID=636256323415
    export SEED_GCP_PROJECT_ID=greenlight-seed
    export SEED_GCP_PROJECT_NAME=greenlight-seed
    export GCP_BILLING_ACCOUNT_ID=01614C-82BAE7-678369
    export TF_BACKEND_BUCKET=tfstate-greenlight
    export SEED_GCP_SERVICE_ACCOUNT=<lookup_fq_sa_username_after_creation>

## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

Run the following commands (once only for the Green Light organization)
    
    gcloud projects create $SEED_GCP_PROJECT_ID --name=$SEED_GCP_PROJECT_NAME --organization=$GCP_ORGANIZATION_ID --set-as-default
    ./setup-sa.sh -o $GCP_ORGANIZATION_ID -p $SEED_GCP_PROJECT_ID -b $GCP_BILLING_ACCOUNT_ID
    gsutil mb -b on -c nearline -p $SEED_GCP_PROJECT_ID gs://$TF_BACKEND_BUCKET
    gsutil versioning set on gs://$TF_BACKEND_BUCKET
    gsutil acl ch -u $SEED_GCP_SERVICE_ACCOUNT:OWNER gs://$TF_BACKEND_BUCKET

## Environment Creation 

If reusing a GCP project

    export TF_VAR_project_id=(project id)
    export TF_VAR_project_name=(project name)
    export TF_VAR_existing_project=true

To create the GCP project, cluster and resources

    # Steps below are temporary and should be used with caution - delete the environment variables after use 
    # Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)

    terraform init \
        && terraform apply -auto-approve -target=google_container_cluster.development \
            -target=google_dns_record_set.apps_name_servers \
            -target=google_dns_record_set.knative_name_servers

Look up the generated NS records for the apps and knative subdomains and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

Add the newly created Kubernetes cluster to your local configuration run:

    $(terraform output kubeconfig_command)

Add Argo CD and wait until all the infrasturce applications are configured. It's complete when all the applications show as configured (green) in the Argo CD UI. The following command installs Argo CD and the infrastructure application:

    terraform apply -auto-approve -target=k8s_manifest.argocd-greenlight-infrastructure-application

Check that the various ingress certificates were correctly configured and if not (due to timeout) delete the affected ingress (or the certificate) and it will be automatically recreated.

Check that the default Kafka Knative Eventing broker was created successfully. It may be in a failed state due to being created
prior to full configuration of Eventing resources. If this is the case, delete the project and the broker will be recreated.

Build the remainder of the Terraform resources:

    terraform apply -auto-approve

Configure a webhook for the [greenlight-coop GitHub organization](https://github.com/organizations/greenlight-coop/settings/hooks/new)
* Create the new GitHub webhook at the greenlight-coop organization level with the following settings:
    * Payload URL: https://argocd.apps.greenlightcoop.dev/api/webhook
        * If using a feature branch and Terraform workspace, revise the above to include the feature suffix 
          (e.g. https://argocd.apps-feature-123.greenlightcoop.dev/api/webhook)
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Just the push event

Create Tekton webhooks for repositories as needed. Example for Node.js Knative Service webhook:
* Create new GitHub webhook in the target project
    * Payload URL: https://tekton.apps.greenlightcoop.dev/webhook/service-pipeline (revise with feature suffix if necessary)
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Send me everything
* Repositories that require https://tekton.apps.greenlightcoop.dev/webhook/service-pipeline webhook:
    * helloworld
* Repositories that require https://tekton.apps.greenlightcoop.dev/webhook/image-pipeline webhook:
    * greenlight-api-tests
    * node-utils
    * serenity-js-runner
    * template-processor
* Repositories that require https://tekton.apps.greenlightcoop.dev/webhook/test-stage-pipeline webhook:
    * greenlight-stage-test


## Update Configuration

    terraform apply

## Removal

    terraform destroy

## Manual Removal

In GCP Console
* Delete cluster (wait for completion)
* Delete Record Sets and Zones in Cloud DNS
* Delete Load Balancers
* Check that all External IP Addresses are deleted (delete if necessary)
* Delete k8s_* Firewall Rules
* Delete Service Accounts

If using a Terraform workspace for isolated cluster testing
* Delete Terraform workspace

        terraform workspace select default
        terraform workspace delete -force feature-<branch number>


### Remove Seed Project

It's expected this will never be required

    gcloud projects delete $SEED_GCP_PROJECT_ID --quiet

## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment (GCP project and cluster) that can then be destroyed
after the modifications have been vetted and merged to master.

* Create a new Terraform workspace, checkout a branch of all repositories based on the current GitHub issue number 
  and push to GitHub.

        ./setup-workspace.sh feature/<feature number>

* Follow the Environment Creation instructions given earlier in this README.

* Iterate between deploying the resources in the new workspace and making changes to the configuration

* When all changes have been merged to master, dispose of the temporary workspace and apply changes to the 
  default workspace from master

        ./teardown-workspace.sh