#!/bin/bash

set -e

FILE_FINAL=/etc/vault.d/vault.hcl
FILE_TMP=$FILE_FINAL.tmp

sudo sed -i -- "s/{{ atlas_environment }}/${atlas_environment}/g" $FILE_TMP

sudo mv $FILE_TMP $FILE_FINAL

sudo service vault start || sudo service vault restart

echo "Vault environment updated."
