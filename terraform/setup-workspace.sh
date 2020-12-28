#!/bin/bash

set -e
set -u
set -x

CWD=$(pwd)
GL_TERRAFORM=$CWD
GL_GIT_BASE=$(cd ../../..; pwd)

BRANCH=$1
TF_WORKSPACE=$(echo $BRANCH | tr '/' '-')

terraform init
terraform workspace new $TF_WORKSPACE

cd $GL_GIT_BASE
meta git checkout -b $BRANCH
meta git push origin --set-upstream $BRANCH