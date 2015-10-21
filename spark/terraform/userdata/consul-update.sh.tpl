#!/bin/bash

set -e

sed -i -- "s/{{ region }}/${region}/g" /etc/init/consul.conf
sed -i -- "s/{{ atlas_username }}/${atlas_username}/g" /etc/init/consul.conf
sed -i -- "s/{{ atlas_token }}/${atlas_token}/g" /etc/init/consul.conf
sed -i -- "s/{{ atlas_environment }}/${atlas_environment}/g" /etc/init/consul.conf
sed -i -- "s/{{ consul_bootstrap_expect }}/${consul_bootstrap_expect}/g" /etc/init/consul.conf
service consul restart

echo "Consul environment updated"

exit 0
