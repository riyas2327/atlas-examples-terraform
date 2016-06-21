#!/bin/bash

KEY_PATH="shared/ssh_keys"
KEY_NAME=$1
EXISTING_KEY=$2

TFVARS_PATH=terraform.tfvars
PRIVATE_KEY_PATH="$KEY_PATH/$KEY_NAME.pem"
PUBLIC_KEY_PATH="$KEY_PATH/$KEY_NAME.pub"

if [ ! -d "$KEY_PATH" ]; then
  echo "Directory [$KEY_PATH] does not exist. This script must be run from the 'consul-cluster' directory."
  exit 1
fi

if [ -z "$1" ]; then
  echo "A key name must be passed as the first argument."
  exit 1
fi

if [ -f "${TFVARS_PATH}" ]; then
  echo "File [${TFVARS_PATH}] already exists. Please remove it first to prevent overwriting."
  exit 1
fi

if [ -s "$PRIVATE_KEY_PATH" ] && [ -s "$PUBLIC_KEY_PATH" ] && [ -z "$EXISTING_KEY" ]; then
    echo "Using existing key pair."
else
    rm -rf $KEY_PATH/$KEY_NAME*

    if [ -z "$EXISTING_KEY" ]; then
      echo "No key pair exists and no private key arg was passed, generating new keys."
      openssl genrsa -out $PRIVATE_KEY_PATH 1024
      chmod 700 $PRIVATE_KEY_PATH
      ssh-keygen -y -f $PRIVATE_KEY_PATH > $PUBLIC_KEY_PATH
      chmod 700 $PUBLIC_KEY_PATH
    else
      echo "Using private key [$EXISTING_KEY] for key pair."
      cp $EXISTING_KEY $PRIVATE_KEY_PATH
      chmod 700 $PRIVATE_KEY_PATH
      ssh-keygen -y -f $PRIVATE_KEY_PATH > $PUBLIC_KEY_PATH
      chmod 700 $PUBLIC_KEY_PATH
    fi
fi

KEY_DATA_PRIVATE="$(cat $PRIVATE_KEY_PATH)"
KEY_DATA_PUBLIC="$(cat $PUBLIC_KEY_PATH)"

cat <<EOF1 >> ${TFVARS_PATH}
key_data_private = <<KEYPRIVATE
${KEY_DATA_PRIVATE}
KEYPRIVATE
EOF1

echo "" >> ${TFVARS_PATH}

cat <<EOF2 >> ${TFVARS_PATH}
key_data_public = <<KEYPUBLIC
${KEY_DATA_PUBLIC}
KEYPUBLIC
EOF2

echo ""
echo "Public key:  $PUBLIC_KEY_PATH"
echo "Private key: $PRIVATE_KEY_PATH"
echo "Vars File:   $TFVARS_PATH"
echo ""
