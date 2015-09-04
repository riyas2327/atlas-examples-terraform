#!/bin/bash

KEY_NAME=$1
EXISTING_KEY=$2
KEY_PATH=../access/keypair/keys
KEY=$KEY_PATH/$KEY_NAME

if [ -s "$KEY.pem" ] && [ -s "$KEY.pub" ] && [ -z "$EXISTING_KEY" ]; then
  echo Using existing key pair
else
  rm -rf $KEY*
  mkdir -p $KEY_PATH

  if [ -z "$EXISTING_KEY" ]; then
    echo No key pair exists and no private key arg was passed, generating new keys...
    openssl genrsa -out $KEY.pem 1024
    chmod 400 $KEY.pem
    ssh-keygen -y -f $KEY.pem > $KEY.pub

    # ssh-keygen -t rsa -b 4096 -C "your@email.com"
    # eval "$(ssh-agent -s)"
    # ssh-add ~/.ssh/id_rsa

    # cd ~/.ssh
    # ssh-keygen -P "" -t rsa -f id_rsa_aws -b 4096 -C "email@example.com"
    # openssl rsa -in ~/.ssh/id_rsa_aws -outform pem > id_rsa_aws.pem
    # chmod 400 id_rsa_aws.pem
    # eval `ssh-agent -s`
    # ssh-add id_rsa_aws.pem
  else
    echo Using private key $EXISTING_KEY for key pair...
    cp $EXISTING_KEY $KEY.pem
    chmod 400 $KEY.pem
    ssh-keygen -y -f $KEY.pem > $KEY.pub
  fi
fi
