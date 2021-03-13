# Green Light Platform Client Projects

## Terraform Module

Create a new directory in the `clients` directory for the client Terraform project.

## Initial GCP Project

* Create an empty GCP project.

* Create a Service Account for Terraform
  
  * Provide the following attributes for the new Service Account
    * Service account name: terraform
    * Service account description: Terraform access for project
  
  * Grant Owner access to project
  
  * Create a key and download credentials
    * Select Manage Keys for the Service Account and then Add Key => Create New Key
    * Key type: JSON
    * Save the generated credentials as `credentials.json` in the client's Terraform project directory.
