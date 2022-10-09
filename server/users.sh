#!/usr/bin/env bash

# Run as etavela

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
echo 'alias k=kubectl' >> ~/.zshrc

sudo cp -f /etc/kubernetes/admin.conf ~/.kube/config

# To get .kube/config on laptop
# scp etavela@link:.kube/config ~/.kube/config