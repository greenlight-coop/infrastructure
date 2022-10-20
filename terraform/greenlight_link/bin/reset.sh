#!/usr/bin/env bash

# Run as root (sudo -i)
# 
# Resets the cluster and associated services on link
#
# Run from remote machine (e.g. MacBook)

set -x

REMOTE_USER=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TF_WORKSPACE=$(terraform workspace show)

rm -rf .terraform terraform.tfstate.d .terraform.lock.hcl
if [ "$TF_WORKSPACE" != "default" ]
then
  terraform workspace new $TF_WORKSPACE
fi

scp $SCRIPT_DIR/clean_server.sh $SCRIPT_DIR/setup_server.sh $REMOTE_USER@link:/tmp/ && \
  ssh -t $REMOTE_USER@link "sudo -s bash /tmp/clean_server.sh && sudo -s bash /tmp/setup_server.sh && mkdir -p ~/.kube/ && sudo cp -f /etc/kubernetes/admin.conf ~/.kube/config && sudo chown $REMOTE_USER ~/.kube/config"

scp $REMOTE_USER@link:.kube/config ~/.kube/config

$SCRIPT_DIR/setup_greenlight.sh