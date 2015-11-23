#!/bin/bash
set -e

apt-get -y update

apt-get -y install curl unzip

# RVM
curl -L https://get.rvm.io | bash
