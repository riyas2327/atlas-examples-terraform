#!/bin/bash
# This script installs nodejs
sudo curl --silent --location https://deb.nodesource.com/setup_0.10 | sudo bash -
sudo apt-get -y update
sudo apt-get -y install nodejs git make g++ libkrb5-dev vim dnsmasq
sudo mkdir /etc/letschat
