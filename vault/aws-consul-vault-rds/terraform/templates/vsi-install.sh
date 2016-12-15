#!/bin/bash

set -ex

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

VSI_VERSION=2016_June_17_v0.1.0-01

sudo apt-get -qq -y update

#######################################
# VSI INSTALL
#######################################

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip wget

# install vault
echo "Downloading VSI..."
cd /tmp/

# TODO: Fix this URL
wget -q https://www.dropbox.com/s/1n6yzbkeqrut1wg/linux_amd64.zip?dl=0 -O vault_vsi.zip

echo "Installing VSI..."
unzip vault_vsi.zip
rm vault_vsi.zip
sudo chmod +x vault-secure-intro
sudo mv vault-secure-intro /usr/bin/vault-secure-intro
sudo mkdir -pm 0600 /etc/vault-secure-intro

#######################################
# VSI CONFIGURATION
#######################################

sudo tee /etc/vault-secure-intro/vault-secure-intro.hcl > /dev/null <<EOF
environment "aws" {
  role = "readonly"
}

vault {
  address = "http://active.vault.service.consul:8200"
  mount_path = "auth/aws-ec2"
}

serve "file" {
  path = "/home/ubuntu/.vault-token"
}

EOF

sudo tee /etc/init/vault-secure-intro.conf > /dev/null <<EOF
description "vault-secure-intro"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

console log

script
  if [ -f "/etc/service/vault-secure-intro" ]; then
    . /etc/service/vault-secure-intro
  fi

  # Make sure to use all our CPUs, because Vault can block a scheduler thread
  export GOMAXPROCS=`nproc`

  exec /usr/bin/vault-secure-intro \
    -config="/etc/vault-secure-intro/vault-secure-intro.hcl" \
    \$${VAULT_FLAGS} \
    >>/var/log/vault-secure-intro.log 2>&1
end script

EOF

#######################################
# START SERVICES
#######################################

sudo service vault-secure-intro start
