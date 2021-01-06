#!/bin/bash
# 
# Run after invoking 'terraform destroy' to clean up from a branched workspace

set -e
set -u
set -x

CWD=$(pwd)
GL_TERRAFORM=$CWD
GL_GIT_BASE=$(cd ../../..; pwd)

TF_WORKSPACE=$(terraform workspace show)
BRANCH=$(echo $TF_WORKSPACE | tr '-' '/')

terraform workspace select default
terraform workspace delete -force $TF_WORKSPACE

cd $GL_GIT_BASE
meta git checkout main
meta git fetch --all
meta git pull
meta git branch -d $BRANCH
meta git push origin --delete $BRANCH