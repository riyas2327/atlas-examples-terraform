#!/bin/bash

set -e

echo "Updating package info..."
sudo apt-get update -y

echo "Upgrading packages..."
sudo apt-get upgrade -y
