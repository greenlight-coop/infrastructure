# Green Light Google Cloud Platform

## One Time Configuration

Prepare an SSH key pair for automated GitHub access, etc. Note that these files are .gitignored and should be protected
for future reference. After generation, add the public key to the bot@greenlight.coop GitHub account. Store the generated
keys in a `./.ssh` directory relative to this `terraform` directory.

    ssh-keygen -t ed25519 -C "bot@greenlight.coop"

## Install Cluster GCP

## Install Cluster with Kind