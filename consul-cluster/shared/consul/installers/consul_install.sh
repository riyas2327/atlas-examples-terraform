#!/bin/bash

set -ex

CONSUL_VERSION=0.6.0-rc1

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip
sudo apt-get install -y curl

# install consul
echo "Fetching consul..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing consul..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -m 777 /etc/consul.d
sudo chmod a+w /var/log
sudo chmod a+w /etc/init/

# setup consul directories
sudo mkdir -p /opt/consul/data

# install consul-web
echo "Fetching consul-web..."
wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip -O consul-web.zip
unzip consul-web.zip -d dist
sudo mv dist /opt/consul/web

echo "Consul installation complete."
