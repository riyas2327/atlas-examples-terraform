#!/bin/bash

set -ex

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

VAULT_VERSION=0.6.2

INSTANCE_PRIVATE_IP=$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{ print $2 }')

#######################################
# VAULT INSTALL
#######################################

# install dependencies
echo "Installing dependencies..."
sudo yum install -q -y unzip wget

# install vault
echo "Downloading Vault..."
cd /tmp/

wget -q https://releases.hashicorp.com/vault/$${VAULT_VERSION}/vault_$${VAULT_VERSION}_linux_amd64.zip -O vault.zip

echo "Installing Vault..."
unzip vault.zip
rm vault.zip
sudo chmod +x vault
sudo mv vault /usr/local/bin/vault
sudo mkdir -pm 0600 /etc/systemd/system/vault.d

#######################################
# VAULT CONFIGURATION
#######################################

sudo tee /etc/systemd/system/vault.d/vault.hcl > /dev/null <<EOF
cluster_name = "${atlas_environment}"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

backend "consul" {
  path           = "vault"
  address        = "127.0.0.1:8500"
}

EOF

sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=vault agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/vault
Restart=on-failure
ExecStart=/usr/local/bin/vault server $$VAULT_FLAGS -config=/etc/systemd/system/vault.d
ExecReload=/bin/kill -HUP $$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

#######################################
# START SERVICES
#######################################

sudo systemctl enable vault.service
sudo systemctl start vault
