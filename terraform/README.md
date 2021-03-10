# Green Light Google Cloud Platform

## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

## Install Cluster GCP

See the README.md in the `greenlight_gcp` directory.

## Install Cluster with Kind

See the README.md in the `greenlight_kind` directory.


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