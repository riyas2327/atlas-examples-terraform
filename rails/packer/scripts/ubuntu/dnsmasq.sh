#!/bin/bash
set -e

apt-get -y install dnsmasq-base dnsmasq

cat <<EOF >/etc/dnsmasq.d/consul
server=/consul/127.0.0.1#8600
listen-address=127.0.0.1
bind-interfaces
EOF

