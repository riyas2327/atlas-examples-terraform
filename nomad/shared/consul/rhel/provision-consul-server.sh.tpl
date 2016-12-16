#!/bin/bash

set -ex

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

CONSUL_VERSION=0.7.0
CONSUL_TEMPLATE_VERSION=0.16.0

INSTANCE_ID=$(curl ${instance_id_url})
INSTANCE_PRIVATE_IP=$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{ print $2 }')

#######################################
# CONSUL
#######################################

# install dependencies
echo "Installing consul dependencies..."
sudo yum install -q -y unzip wget

# install consul
echo "Fetching consul..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing consul..."
unzip consul.zip
rm consul.zip
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -pm 0600 /etc/systemd/system/consul.d

# setup consul directories
sudo mkdir -pm 0600 /opt/consul
sudo mkdir -p /opt/consul/data

echo "Consul installation complete."

#######################################
# CONSUL CONFIGURATION
#######################################

sudo tee /etc/systemd/system/consul.d/consul.json > /dev/null <<EOF
{
  "atlas_join": true,
  "atlas_infrastructure": "${atlas_username}/${atlas_environment}",
  "atlas_token": "${atlas_token}",

  "node_name": "$$INSTANCE_ID",

  "data_dir": "/opt/consul/data",
  "ui": true,

  "client_addr": "0.0.0.0",
  "bind_addr": "0.0.0.0",
  "advertise_addr": "$$INSTANCE_PRIVATE_IP",

  "leave_on_terminate": false,
  "skip_leave_on_interrupt": true,

  "datacenter": "${region}",
  "server": true,
  "bootstrap_expect": ${consul_server_nodes}
}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent $$CONSUL_FLAGS -config-dir=/etc/systemd/system/consul.d
ExecReload=/bin/kill -HUP $$MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

#######################################
# CONSUL-TEMPLATE
#######################################

# install dependencies
echo "Installing consul-template dependencies..."
sudo yum install -q -y unzip wget

# install consul-template
echo "Fetching consul-template..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul-template/$${CONSUL_TEMPLATE_VERSION}/consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O consul-template.zip

echo "Installing consul-template..."
unzip consul-template.zip
rm consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

echo "Consul-template installation complete."

#######################################
# DNSMASQ
#######################################

echo "Installing Dnsmasq..."

sudo yum install -q -y dnsmasq

echo "Configuring Dnsmasq..."

sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."

#######################################
# START SERVICES
#######################################

sudo systemctl enable consul.service
sudo systemctl start consul
