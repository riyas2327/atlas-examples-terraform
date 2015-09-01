#!/bin/bash

set -e

CT_VERSION=0.10.0

echo "Fetching consul-template..."
wget -q https://github.com/hashicorp/consul-template/releases/download/v${CT_VERSION}/consul-template_${CT_VERSION}_linux_amd64.tar.gz
echo "Installing consul-template..."
tar xzf consul-template_${CT_VERSION}_linux_amd64.tar.gz
sudo mv consul-template_${CT_VERSION}_linux_amd64/consul-template /usr/bin
sudo rmdir consul-template_${CT_VERSION}_linux_amd64
sudo mkdir -m 777 /etc/ctmpl

echo "consul-template installation complete."
