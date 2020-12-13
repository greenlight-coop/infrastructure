#!/bin/bash

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
GL_STAGING=$GL_STAGES/argocd-greenlight-staging
GL_PRODUCTION=$GL_STAGES/argocd-greenlight-production
GL_SOFTWARE=$GL_GIT_BASE/software
GL_HELM_CHARTS=$GL_SOFTWARE/greenlight-helm-charts

BRANCH=$1
TF_WORKSPACE=$(echo $BRANCH | tr '/' '-')

terraform init
terraform workspace new $TF_WORKSPACE
git checkout -b $BRANCH
git push --set-upstream origin $BRANCH

cd $GL_ARGOCD_INFRA
git checkout -b $BRANCH
git push --set-upstream origin $BRANCH

cd $GL_STAGING
git checkout -b $BRANCH
git push --set-upstream origin $BRANCH

cd $GL_PRODUCTION
git checkout -b $BRANCH
git push --set-upstream origin $BRANCH

cd $GL_HELM_CHARTS
git checkout -b $BRANCH
git push --set-upstream origin $BRANCH