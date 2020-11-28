# Green Light Google Cloud Platform

## Prepare environment

Global for all instructions that follow


## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

## Environment Creation 

To create the resources

    # Steps below are temporary and should be used with caution - delete the environment variables after use 
    # Another option is to supply the values when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)

    terraform init \
        && tf apply -auto-approve -target=data.kubernetes_service.ingress-nginx-controller

Look up the generated NS records for the api, apps, ingress and knative subdomains and add NS records for these name 
servers in the Google Domains managed greenlightcoop.dev domain.

Add Argo CD and wait until all the infrasturce applications are configured. It's complete when all the applications show as
configured (green) in the Argo CD UI and the Knative ingress external IP is available. The following commands configure 
the Argo CD infrastructure application and check for the Knative ingress:

    terraform apply -auto-approve -target=k8s_manifest.argocd-greenlight-infrastructure-application
    kubectl get svc -n istio-system

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

Create Tekton webhooks for service projects as needed. Example for Node.js webhook:
* Create new GitHub webhook in the target project
    * Payload URL: https://tekton.apps.greenlightcoop.dev/webhook/node-pipeline (revise with feature suffix if necessary)
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Send me everything

## Update Configuration

    terraform apply

## Removal

    terraform destroy

### Remove Seed Project

It's expected this will never be required

    gcloud projects delete $SEED_GCP_PROJECT_ID --quiet

## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment (GCP project and cluster) that can then be destroyed
after the modifications have been vetted and merged to master.

* Checkout a branch of the infrastructure, argocd-greenlight-infrastructure, argocd-greenlight-staging, 
  argocd-greenlight-production, and greenlight-helm-charts projects based on the current GitHub 
  issue number and push to GitHub.

        git checkout -b feature/<issue number> && git push --set-upstream origin $(git_current_branch)

* Create a new workspace using the issue number as part of the workspace name, replacing '/' with '-'

        terraform workspace new feature-<issue number>

* Follow the Environment Creation instructions given earlier in this README.

* Iterate between deploying the resources in the new workspace and making changes to the configuration

        terraform apply
        $(terraform output kubeconfig_command)

* When all changes have been merged to master, dispose of the temporary workspace and apply changes to the 
  default workspace from master

        terraform destroy
        terraform workspace select default
        terraform workspace delete feature-<issue number>
        git checkout master && git pull
        terraform apply