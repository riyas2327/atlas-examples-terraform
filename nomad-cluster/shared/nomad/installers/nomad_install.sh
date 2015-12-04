#!/bin/bash

set -ex

NOMAD_VERSION=0.2.1

apt-get -y update

# install dependencies
echo "Installing dependencies..."
apt-get install -y curl
apt-get install -y unzip

# install nomad
echo "Fetching nomad..."
cd /tmp/
wget -q https://dl.bintray.com/mitchellh/nomad/nomad_0.1.2_linux_amd64.zip -O nomad.zip
wget -q https://releases.hashicorp.com/consul/${NOMAD_VERSION}/consul_${NOMAD_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing nomad..."
unzip nomad.zip
rm nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -m 0600 /etc/nomad.d

# setup nomad directories
sudo mkdir -m 0600 /opt/nomad
sudo mkdir /opt/nomad/data

echo "Nomad installation complete."
