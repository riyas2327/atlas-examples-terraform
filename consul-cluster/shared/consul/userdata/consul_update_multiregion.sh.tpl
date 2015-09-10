#!/bin/bash

set -e

FILE_FINAL=/etc/consul.d/consul.json
FILE_TMP=$FILE_FINAL.tmp

sed -i -- "s/{{ region }}/${region}/g" $FILE_TMP
sed -i -- "s/{{ atlas_token }}/${atlas_token}/g" $FILE_TMP
sed -i -- "s/{{ atlas_organization }}/${atlas_organization}/g" $FILE_TMP
sed -i -- "s/{{ atlas_environment }}/${atlas_environment}/g" $FILE_TMP
# Note: consul_bootstrap_expect isn't required for consul clients, only servers.
sed -i -- "s/{{ consul_bootstrap_expect }}/${consul_bootstrap_expect}/g" $FILE_TMP

# Note: placeholders below replaced by bash, not the Terraform go template.
METADATA_INSTANCE_ID=`curl http://169.254.169.254/2014-02-25/meta-data/instance-id`
sed -i -- "s/{{ instance_id }}/$METADATA_INSTANCE_ID/g" $FILE_TMP
METADATA_PUBLIC_IPV4=`curl http://169.254.169.254/2014-02-25/meta-data/public-ipv4`
sed -i -- "s/{{ public_ipv4 }}/$METADATA_PUBLIC_IPV4/g" $FILE_TMP

sudo mv $FILE_TMP $FILE_FINAL
sudo service consul start

echo "Consul environment updated."

exit 0
