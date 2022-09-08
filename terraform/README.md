# Green Light Platform

## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

## Deploy Green Light Development Platform

### Preparation

Each platform set up Terraform config requires a `secrets.auto.tfvars` to specify required sensitive values that can't be
checked in to source control.

### Setup

Execute the `setup.sh` script in either the `greenlight_digitalocean` or `greenlight_kind` directory.

See the README.md in the `greenlight_digitalocean` or `greenlight_kind` directory for additional details.

Note that if setting up a feature workspace via `greenlight_digitalocean` it's important to update the domain NS records 
in Google Domains, e.g.

|  Host name                        | Type | TTL       | Data                  |
| --------------------------------- | ---- | --------- | --------------------- |
| app-feature-15.greenlightcoop.dev | NS   | 5 minutes | ns1.digitalocean.com. |
|                                   |      |           | ns2.digitalocean.com. |
|                                   |      |           | ns3.digitalocean.com. |

### Configure GitHub Webooks

Configure a webhook for the [greenlight-coop GitHub organization](https://github.com/organizations/greenlight-coop/settings/hooks/new)
* Create the new GitHub webhook at the greenlight-coop organization level with the following settings:
    * Payload URL:
        * Main: https://argocd.app-home.greenlightcoop.dev/api/webhook
        * GCP workspace: https://argocd.app-feature-nnn.greenlightcoop.dev/api/webhook
        * kind cluster: https://argocd.app-home.greenlightcoop.dev/api/webhook
    * Content type: application/json
    * Secret: the generated webhook_secret value from Terraform output
    * Which events...: Just the push event

Create Tekton webhooks for repositories as needed. Example for Node.js Knative Service webhook:
* Create new GitHub webhook in the target project
    * Payload URL:
        * Main: https://tekton.app-home.greenlightcoop.dev/webhook/service-pipeline
        * GCP workspace: https://tekton.app-feature-nnn.greenlightcoop.dev/webhook/service-pipeline
        * kind cluster: https://tekton.app-home.greenlightcoop.dev/webhook/service-pipeline
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
have been vetted and merged to main. This may be done in either a GCP or Kind cluster environment.

* Create a new Terraform workspace, checkout a branch of all repositories based on the current GitHub issue number 
  and push to GitHub. Commands should be run in either the `greenlight_digitalocean` or `greenlight_kind` subdirectory.

      meta git checkout -b feature/<n>
      meta git push origin --set-upstream feature/<n>
      terraform init
      terraform workspace new feature-<n> 

* Follow the Deploy Green Light Development Platform instructions given earlier in the corresponding environment README.

* Iterate between deploying the resources in the new workspace and making changes to the configuration

* When all changes have been merged to main, dispose of the temporary workspace and apply changes to the 
  default workspace from main

      meta git fetch --all
      meta git checkout main
      meta git pull
      meta git diff feature/<n>     # Check that all changes have been merged
      meta git branch -D feature/<n>
      meta git push origin --delete feature/<n>
      terraform workspace select default    # Run cleanup script before this step
      terraform workspace delete -force feature-<n>

## Resources

### Keycloak

* Get Keycloak admin password

      export KEYCLOAK_PASSWORD=$(kubectl get secret -n keycloak credential-keycloak -o 'jsonpath={.data.ADMIN_PASSWORD}' | base64 -d)
      echo $KEYCLOAK_PASSWORD | pbcopy

### k8ssandra

* Get k8ssandra superuser and password

      kubectl get secret -n k8ssandra-operator k8ssandra-superuser -o json | jq -r '.data.username' | base64 --decode
      kubectl get secret -n k8ssandra-operator k8ssandra-superuser -o json | jq -r '.data.password' | base64 --decode

* Connect to cqlsh as superuser

      k exec -it k8ssandra-dc1-default-sts-0 -c cassandra -n k8ssandra-operator -- cqlsh \
        -u k8ssandra-superuser \
        -p $(kubectl get secret -n k8ssandra-operator k8ssandra-superuser -o json | jq -r '.data.password' | base64 --decode) 
        
### Ceph

* Get Ceph Dashboard admin password:

      kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo