#!/bin/bash
# This script installs mongodb
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | sudo tee -a /etc/apt/sources.list.d/10gen.list
sudo apt-get -y update
sudo apt-get -y install git mongodb-10gen vim curl

# Configuring Database: Very basic example
sudo mongo letschat --eval 'db.addUser({user: "lcadmin",pwd: "bacon&eggs",roles: ["dbAdmin"],})'
