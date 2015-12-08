#!/bin/bash

set -ex

NOMAD_VERSION=0.2.1

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y curl
sudo apt-get install -y unzip

# install nomad
echo "Fetching nomad..."
cd /tmp/
wget -q https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -O nomad.zip

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
