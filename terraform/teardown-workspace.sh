#!/bin/bash
# 
# Run after invoking 'terraform destroy' to clean up from a branched workspace

set -e
set -u
set -x

CWD=$(pwd)
GL_TERRAFORM=$CWD
GL_GIT_BASE=$(cd ../../..; pwd)
GL_DEVOPS=$GL_GIT_BASE/devops
GL_INFRA=$GL_DEVOPS/infrastructure
GL_ARGOCD_INFRA=$GL_DEVOPS/argocd-greenlight-infrastructure
GL_STAGES=$GL_GIT_BASE/stages
GL_STAGE_TEST=$GL_STAGES/greenlight-stage-test
GL_SOFTWARE=$GL_GIT_BASE/software
GL_HELM_CHARTS=$GL_SOFTWARE/greenlight-helm-charts

TF_WORKSPACE=$(terraform workspace show)
BRANCH=$(echo $TF_WORKSPACE | tr '-' '/')

cd $GL_HELM_CHARTS
git checkout main
git pull
git branch -d $BRANCH
git push origin --delete $BRANCH

cd $GL_STAGE_TEST
git checkout main
git pull
git branch -d $BRANCH
git push origin --delete $BRANCH

cd $GL_ARGOCD_INFRA
git checkout main
git pull
git branch -d $BRANCH
git push origin --delete $BRANCH

cd $GL_TERRAFORM
git checkout master
git pull
git branch -d $BRANCH
git push origin --delete $BRANCH

terraform workspace select default
terraform workspace delete $TF_WORKSPACE
