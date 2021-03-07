# Green Light Development Platform

## Deploy Green Light Development Platform

    terraform init \
      && terraform apply -auto-approve 


## Terraform Workspace

To test non-trivial infrastructure configuration changes, it's recommended to use a Terraform workspace. This allows
for deployment of the infrastructure to a temporary environment (GCP project and cluster) that can then be destroyed
after the modifications have been vetted and merged to master.

* Create a new Terraform workspace, checkout a branch of all repositories based on the current GitHub issue number 
  and push to GitHub.

      meta git checkout -b feature/<n>
      meta git push origin --set-upstream feature/<n>
      terraform workspace new feature-<n> 

* Follow the Deploy Green Light Development Platform instructions given earlier in this README.

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