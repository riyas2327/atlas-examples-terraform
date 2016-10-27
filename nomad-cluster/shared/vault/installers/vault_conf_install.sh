#!/bin/bash

set -ex

sudo mv /tmp/vault.conf /etc/init/
sudo mv /tmp/vault.hcl.tmp /etc/vault.d/
