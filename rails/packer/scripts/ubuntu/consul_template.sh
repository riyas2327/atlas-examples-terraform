#!/bin/bash
set -e

cd /tmp

CTDOWNLOAD=https://releases.hashicorp.com/consul-template/0.11.1/consul-template_0.11.1_linux_amd64.zip
CTCONFIGDIR=/etc/consul_template.d
CTDIR=/opt/consul_template

echo Fetching Consul Template...
curl -L $CTDOWNLOAD > /tmp/consul_template.zip

echo Installing Consul Template...
unzip /tmp/consul_template.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/consul-template
chown root:root /usr/local/bin/consul-template

echo Configuring Consul Template...
mkdir -p $CTCONFIGDIR $CTDIR
chmod 755 $CTCONFIGDIR $CTDIR

mv $CONFIGDIR/consul_template/base.hcl $CTCONFIGDIR/base.hcl
mv $CONFIGDIR/consul_template/consul_template.conf /etc/init/consul_template.conf
