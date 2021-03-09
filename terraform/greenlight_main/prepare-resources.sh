CWD=$(pwd)
DEVELOPMENT_CLUSTER_MODULE_DIRECTORY=$(cd ../modules/development_cluster_configuration; pwd)

# Prepare buildkit certificates
CAROOT=$DEVELOPMENT_CLUSTER_MODULE_DIRECTORY/.certs
mkdir -p $CAROOT/client $CAROOT/daemon 
mkcert -cert-file $CAROOT/daemon/cert.pem -key-file $CAROOT/daemon/key.pem buildkitd >/dev/null 2>&1
mkcert -client -cert-file $CAROOT/client/cert.pem -key-file $CAROOT/client/key.pem client >/dev/null 2>&1
cp -f $CAROOT/rootCA.pem $CAROOT/daemon/ca.pem
cp -f $CAROOT/rootCA.pem $CAROOT/client/ca.pem