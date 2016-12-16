#!/bin/bash

set -ex

CONSUL_VERSION=0.7.0
CONSUL_TEMPLATE_VERSION=0.16.0

#######################################
# CONSUL
#######################################

# install dependencies
echo "Installing consul dependencies..."
sudo apt-get -qq -y update
sudo apt-get install -qq -y unzip wget

# install consul
echo "Fetching consul..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing consul..."
unzip consul.zip
rm consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -pm 0600 /etc/consul.d

# setup consul directories
sudo mkdir -pm 0600 /opt/consul
sudo mkdir -p /opt/consul/data

echo "Consul installation complete."

#######################################
# CONSUL-TEMPLATE
#######################################

# install dependencies
echo "Installing consul-template dependencies..."
sudo apt-get -qq -y update
sudo apt-get install -qq -y unzip wget

# install consul-template
echo "Fetching consul-template..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O consul-template.zip

echo "Installing consul-template..."
unzip consul-template.zip
rm consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

echo "Consul-template installation complete."
