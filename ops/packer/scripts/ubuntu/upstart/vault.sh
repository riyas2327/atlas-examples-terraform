#!/bin/sh

echo Creating Vault server configuration...

CERT_NAME=$1
CERTS_DIR=/ops/terraform/access/cert/certs
VAULT_DIR=/usr/local/etc
BASHRCPATH=~/.bashrc

cp /ops/packer/scripts/ubuntu/upstart/vault.conf /etc/init/.
cp $CERTS_DIR/$CERT_NAME.crt $VAULT_DIR/.
cp $CERTS_DIR/$CERT_NAME.key $VAULT_DIR/.

# Add cert env var to be reference by -ca-cert in Vault commands
sh -c echo -e "\n" >> $BASHRCPATH
echo "export VAULT_CA_CERT=$VAULT_DIR/$CERT_NAME.crt" | tee -a $BASHRCPATH

# http://vaultproject.io/docs/config/
cat <<EOF >/etc/vault.d/vault_config.hcl
backend "consul" {
  path = "vault"
  address = "127.0.0.1:8500"
  advertise_addr = "http://{{ node_name }}"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "$VAULT_DIR/$CERT_NAME.crt"
  tls_key_file = "$VAULT_DIR/$CERT_NAME.key"
}
EOF
