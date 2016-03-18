#!/bin/bash

sudo curl -sSL https://get.docker.com/ | sh
sudo sh -c "echo \"DOCKER_OPTS='--dns 172.17.42.1 --dns 127.0.0.1 --dns 8.8.8.8 --dns-search service.consul'\" >> /etc/default/docker"
usermod -aG docker ubuntu
sudo service docker restart
