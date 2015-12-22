#!/bin/bash

sudo curl -sSL https://get.docker.com/ | sh
sudo echo "DOCKER_OPTS='--dns 172.17.42.1 --dns 8.8.8.8 --dns-search service.consul'" >> /etc/default/docker
