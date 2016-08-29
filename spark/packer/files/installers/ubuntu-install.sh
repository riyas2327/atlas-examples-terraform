#!/bin/bash

set -e

echo "Updating package info..."
sudo apt-get update -y -qq

echo "Upgrading packages..."
sudo apt-get dist-upgrade -y -qq
