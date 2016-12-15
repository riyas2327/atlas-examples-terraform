#!/bin/bash

set -ex

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

VAULT_VERSION=0.6.2

INSTANCE_PRIVATE_IP=$(ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }')

sudo apt-get -qq -y update

#######################################
# VAULT INSTALL
#######################################

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip wget

# install vault
echo "Downloading Vault..."
cd /tmp/

wget -q https://releases.hashicorp.com/vault/$${VAULT_VERSION}/vault_$${VAULT_VERSION}_linux_amd64.zip -O vault.zip

echo "Installing Vault..."
unzip vault.zip
rm vault.zip
sudo chmod +x vault
sudo mv vault /usr/bin/vault
sudo mkdir -pm 0600 /etc/vault.d
