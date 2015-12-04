#!/bin/bash

set -ex

CONSUL_VERSION=0.6.0

apt-get -y update

# install dependencies
echo "Installing dependencies..."
apt-get install -y unzip
apt-get install -y curl

# install consul
echo "Fetching consul..."
cd /tmp/
wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing consul..."
unzip consul.zip
rm consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -m 0600 /etc/consul.d

# setup consul directories
sudo mkdir -m 0600 /opt/consul
sudo mkdir /opt/consul/data
sudo mkdir /opt/consul/web

# install consul-web
echo "Fetching consul-web..."
wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip -O consul-web.zip
sudo unzip consul-web.zip -d /opt/consul/web

echo "Consul installation complete."
