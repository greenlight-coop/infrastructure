#!/usr/bin/env bash

set -ex

CWD=$(pwd)
DEVELOPMENT_CLUSTER_MODULE_DIRECTORY=$(cd modules/development_cluster_configuration; pwd)

# Prepare buildkit certificates
CERTS_DIRECTORY=$DEVELOPMENT_CLUSTER_MODULE_DIRECTORY/.certs
mkdir -p $CERTS_DIRECTORY/client $CERTS_DIRECTORY/daemon 
CAROOT=$CERTS_DIRECTORY mkcert -cert-file $CERTS_DIRECTORY/daemon/cert.pem -key-file $CERTS_DIRECTORY/daemon/key.pem buildkitd >/dev/null 2>&1
CAROOT=$CERTS_DIRECTORY mkcert -client -cert-file $CERTS_DIRECTORY/client/cert.pem -key-file $CERTS_DIRECTORY/client/key.pem client >/dev/null 2>&1
cp -f $CERTS_DIRECTORY/rootCA.pem $CERTS_DIRECTORY/daemon/ca.pem
cp -f $CERTS_DIRECTORY/rootCA.pem $CERTS_DIRECTORY/client/ca.pem