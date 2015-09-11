#!/bin/bash
set -e

usage() {
  cat <<EOF
Generate a self-signed SSL cert

Prerequisites:

Requires openssl is installed and available on \$PATH.

Usage:

  $0 <BASE_DOMAIN> <COMPANY> <NAME>

Where BASE_DOMAIN is the domain to be deployed, COMPANY is your companies name, and NAME is the name of the environment.

This will generate a single self-signed cert with the following subjectAltNames:

 * BASE_DOMAIN
 * vault.BASE_DOMAIN
 * vpn.BASE_DOMAIN
 * NAME-vault.1
 * NAME-vault.2
 * NAME-vault.3
EOF

  exit 1
}

if ! which openssl > /dev/null; then
  echo
  echo "ERROR: The openssl executable was not found. This script requires openssl."
  echo
  usage
fi

DOMAIN=$1

if [ "x$DOMAIN" == "x" ]; then
  echo
  echo "ERROR: Specify base domain as the first argument, e.g. mycompany.com"
  echo
  usage
fi

COMPANY=$2

if [ "x$COMPANY" == "x" ]; then
  echo
  echo "ERROR: Specify company as the second argument, e.g. HashiCorp"
  echo
  usage
fi

NAME=$3

if [ "x$NAME" == "x" ]; then
  echo
  echo "ERROR: Specify name as the third argument, e.g. production"
  echo
  usage
fi

# Create a temporary build dir and make sure we clean it up. For
# debugging, comment out the trap line.
BUILDDIR=`mktemp -d /tmp/ssl-XXXXXX`
trap "rm -rf $BUILDDIR" INT TERM EXIT

BASEDIR=../terraform/certs
BASENAME="$BASEDIR/$NAME"
CSR="${BASENAME}.csr"
KEY="${BASENAME}.key"
CRT="${BASENAME}.crt"
SSLCONF=${BUILDDIR}/selfsigned_openssl.cnf
mkdir -p $BASEDIR

cp openssl.cnf ${SSLCONF}
(cat <<EOF
[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = vault.${DOMAIN}
DNS.3 = vpn.${DOMAIN}
DNS.4 = ${NAME}-vault.1
DNS.5 = ${NAME}-vault.2
DNS.6 = ${NAME}-vault.3

IP.1 = 0.0.0.0
IP.2 = 127.0.0.1
EOF
) >> $SSLCONF

SUBJ="/C=US/ST=California/L=San Francisco/O=$COMPANY/OU=$NAME/CN=${DOMAIN}"

openssl genrsa -out $KEY 2048
openssl req -new -out $CSR -key $KEY -subj "${SUBJ}" -config $SSLCONF
openssl x509 -req -days 3650 -in $CSR -signkey $KEY -out $CRT -extensions v3_req -extfile $SSLCONF
