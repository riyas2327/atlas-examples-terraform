#!/bin/bash

set -ex

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

NOMAD_VERSION=0.4.1

INSTANCE_ID=$(curl ${instance_id_url})
INSTANCE_PRIVATE_IP=$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{ print $2 }')

#######################################
# NOMAD INSTALL
#######################################

# install dependencies
echo "Installing dependencies..."
sudo yum install -q -y unzip wget

# install nomad
echo "Fetching nomad..."
cd /tmp/

wget -q https://releases.hashicorp.com/nomad/$${NOMAD_VERSION}/nomad_$${NOMAD_VERSION}_linux_amd64.zip -O nomad.zip

echo "Installing nomad..."
unzip nomad.zip
rm nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad
sudo mkdir -pm 0600 /etc/systemd/system/nomad.d

# setup nomad directories
sudo mkdir -pm 0600 /opt/nomad
sudo mkdir -p /opt/nomad/data

echo "Nomad installation complete."

#######################################
# NOMAD CONFIGURATION
#######################################

sudo tee /etc/systemd/system/nomad.d/nomad.hcl > /dev/null <<EOF
name       = "$$INSTANCE_ID"
data_dir   = "/opt/nomad/data"
datacenter = "${region}"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = ${nomad_server_nodes}
}

addresses {
  rpc  = "$$INSTANCE_PRIVATE_IP"
  serf = "$$INSTANCE_PRIVATE_IP"
}

advertise {
  http = "$$INSTANCE_PRIVATE_IP:4646"
}

consul {
}

EOF

sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOF
[Unit]
Description=nomad agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/nomad
Restart=on-failure
ExecStart=/usr/local/bin/nomad agent $$NOMAD_FLAGS -config=/etc/systemd/system/nomad.d
ExecReload=/bin/kill -HUP $$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

#######################################
# START SERVICES
#######################################

sudo systemctl enable nomad.service
sudo systemctl start nomad
