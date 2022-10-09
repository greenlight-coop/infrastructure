#!/usr/bin/env bash

# Run as etavela

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
echo 'alias k=kubectl' >> ~/.zshrc

sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config