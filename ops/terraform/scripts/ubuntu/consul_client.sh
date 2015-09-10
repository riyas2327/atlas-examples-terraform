#!/bin/sh

sed -i -- "s/{{ atlas_username }}/${atlas_username}/g" /etc/consul.d/config.json
sed -i -- "s/{{ atlas_environment }}/${atlas_environment}/g" /etc/consul.d/config.json
sed -i -- "s/{{ atlas_token }}/${atlas_token}/g" /etc/consul.d/config.json
sed -i -- "s/{{ datacenter }}/${atlas_environment}/g" /etc/consul.d/config.json
sed -i -- "s/{{ service }}/${service}/g" /etc/consul.d/config.json

# Because we can't create unique names for nodes launched in LC's/AGS's, we append the local ip
# sed -i -- "s/{{ node_name }}/${node_name}/g" /etc/consul.d/config.json # Replace with node_name
# sed -i -- "s/\"node_name\": \"{{ node_name }}\",//g" /etc/consul.d/config.json # Remove node_name completely
sed -i -- "s/{{ node_name }}/${node_name}.{{ node_name }}/g" /etc/consul.d/config.json
sed -i -- "s/{{ node_name }}/$(hostname)/g" /etc/consul.d/config.json

service consul restart

echo "Consul config updated"

exit 0
