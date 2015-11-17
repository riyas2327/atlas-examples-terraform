#!/bin/bash

set -e

cd /tmp

CONSULURL=https://releases.hashicorp.com/consul/0.6.0-rc1/consul_0.6.0-rc1_linux_amd64.zip
CONSULUI=https://releases.hashicorp.com/consul/0.6.0-rc1/consul_0.6.0-rc1_web_ui.zip
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

curl -L $CONSULURL > /tmp/consul.zip

unzip /tmp/consul.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

mkdir -p $CONSULDIR $CONSULCONFIGDIR
chmod 755 $CONFIGDIR $CONSULDIR

curl -L $CONSULUI > /tmp/ui.zip
unzip /tmp/ui.zip -d $CONSULDIR/ui

mv $CONFIGDIR/consul/consul_client.json $CONSULCONFIGDIR/base.json
mv $CONFIGDIR/consul/consul.conf /etc/init/consul.conf
