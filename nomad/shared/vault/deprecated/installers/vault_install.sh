#!/bin/bash

set -ex

VAULT_VERSION=0.6.2

sudo apt-get -qq -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip wget

# install vault
echo "Downloading Vault..."
cd /tmp/

wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O vault.zip

echo "Installing Vault..."
unzip vault.zip
rm vault.zip
sudo chmod +x vault
sudo mv vault /usr/bin/vault
sudo mkdir -pm 0600 /etc/vault.d

echo "Vault installation complete."
