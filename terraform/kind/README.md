# Green Light Kind Configuration

## Environment Creation 

Ensure that current `home` DNS records reflect the current IP address.

Manually generate the Let's Encrypt certificates and private key using the following command:

    sudo certbot -d 'apps-home.greenlightcoop.dev' -d '*.apps-home.greenlightcoop.dev' certonly --manual

Create the cluster and resources

    # Steps below are temporary and should be used with caution - delete the environment variables after use 
    # Another option is to supply the values on the command line or when prompted

    export TF_VAR_bot_password=(Green Light bot password value)
    export TF_VAR_bot_github_token=(Green Light GitHub access token)
    export TF_VAR_webhook_secret=(Green Light GitHub webhook HMAC token value)
    export TF_VAR_kind_tls_crt=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/fullchain.pem)
    export TF_VAR_kind_tls_key=$(sudo cat /etc/letsencrypt/live/apps-home.greenlightcoop.dev/privkey.pem)

    terraform init \
        && terraform apply -auto-approve -target=null_resource.kind_greenlight

Install Argo CD and wait for all the services and pods to become available.

    terraform apply -auto-approve -target=module.greenlight.null_resource.argocd
    kubectl -n argocd get all

Add Argo CD and wait until all the infrasturce applications are configured. It's complete when all the applications show as configured (green) in the Argo CD UI. The following command installs Argo CD and the infrastructure application:

    terraform apply -auto-approve -target=module.greenlight.k8s_manifest.argocd-greenlight-infrastructure-application

Check that the default Kafka Knative Eventing broker was created successfully. It may be in a failed state due to being created
prior to full configuration of Eventing resources. If this is the case, delete the project and the broker will be recreated.

Build the remainder of the Terraform resources:

    terraform apply -auto-approve

Configure a webhook for the [greenlight-coop GitHub organization](https://github.com/organizations/greenlight-coop/settings/hooks/new)
* Create the new GitHub webhook at the greenlight-coop organization level with the following settings:
    * Payload URL: https://argocd.apps-home.greenlightcoop.dev/api/webhook
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Just the push event

Create Tekton webhooks for repositories as needed. Example for Node.js Knative Service webhook:
* Create new GitHub webhook in the target project
    * Payload URL: https://tekton.apps-home.greenlightcoop.dev/webhook/service-pipeline (revise with feature suffix if necessary)
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Send me everything
* Repositories that require https://tekton.apps-home.greenlightcoop.dev/webhook/service-pipeline webhook:
    * helloworld
* Repositories that require https://tekton.apps-home.greenlightcoop.dev/webhook/image-pipeline webhook:
    * greenlight-api-tests
    * greenlight-ui-tests
    * helloworld-ui
    * node-utils
    * serenity-js-runner
    * template-processor
* Repositories that require https://tekton.apps-home.greenlightcoop.dev/webhook/test-stage-pipeline webhook:
    * greenlight-stage-test

## Update Configuration

    terraform apply

## Removal

    terraform destroy

## Manual Removal

kind delete cluster --name greenlight

If using a Terraform workspace for isolated cluster testing
* Delete Terraform workspace

        terraform workspace select default
        terraform workspace delete -force feature-<branch number>

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