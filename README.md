# Green Light Software Cooperative Infrastructure

Green Light Software Cooperative environment set up and configuration instructions and
artifacts.

## Developer Tool Configurations

See the markdown files in the `developer` directory for instructions on configuring
development machines.

* [macOS.md](developer/macOS.md)

## Google Cloud Platform

See the [README.md](terraform/README.md) in the `terraform` directory for instructions on creating or updating GCP
resources for Green Light.

## Argo CD

See the artifacts in the `argocd-greenlight-infrastructure` and `argocd-greenlight-software` repositories for 
information on how Argo CD is configured to manage the Kubernetes environment and installed services.

## DNS

DNS for the domain greenlight.coop is managed at https://marcaria.com/.

Development work will be performed using teh domain greenlightcoop.dev. This domain is managed in Google Domains and
subdomains are managed in GCP Cloud DNS.

## Public Website

The public website is https://greenlight.coop.

Website management is hosted at https://dashboard.webhosting.coop/index.php.

Public website content is stored in the [greenlight/www]() project in GitHub.