#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT pqs.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
  echo "$DT pqs.sh: $1"
}

logger "Begin script"
sleep 10 # Wait for Consul service to fully boot

CONSUL_ADDR=http://127.0.0.1:8500

logger "Temporarily registering redis service for Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX PUT \
    -d '{ "Name": "redis" }' \
    $CONSUL_ADDR/v1/agent/service/register
)"

logger "Registering Redis Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX POST \
    -d \
'{
  "Name": "redis",
  "Service": {
    "Service": "redis",
    "Failover": {
      "NearestN": 3
    },
    "OnlyPassing": true,
    "Tags": ["global"]
  },
  "DNS": {
    "TTL": "10s"
  }
}' $CONSUL_ADDR/v1/query
)"

logger "Deregistering Redis service"
logger "$(
  curl $CONSUL_ADDR/v1/agent/service/deregister/redis
)"

logger "Temporarily registering nodejs service for Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX PUT \
    -d '{ "Name": "nodejs" }' \
    $CONSUL_ADDR/v1/agent/service/register
)"

logger "Registering nodejs Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX POST \
    -d \
'{
  "Name": "nodejs",
  "Service": {
    "Service": "nodejs",
    "Failover": {
      "NearestN": 3
    },
    "OnlyPassing": true,
    "Tags": ["global"]
  },
  "DNS": {
    "TTL": "10s"
  }
}' $CONSUL_ADDR/v1/query
)"

logger "Deregistering nodejs service"
logger "$(
  curl $CONSUL_ADDR/v1/agent/service/deregister/nodejs
)"

logger "Temporarily registering nginx service for Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX PUT \
    -d '{ "Name": "nginx" }' \
    $CONSUL_ADDR/v1/agent/service/register
)"

logger "Registering nginx Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX POST \
    -d \
'{
  "Name": "nginx",
  "Service": {
    "Service": "nginx",
    "Failover": {
      "NearestN": 3
    },
    "OnlyPassing": true,
    "Tags": ["global"]
  },
  "DNS": {
    "TTL": "10s"
  }
}' $CONSUL_ADDR/v1/query
)"

logger "Deregistering nginx service"
logger "$(
  curl $CONSUL_ADDR/v1/agent/service/deregister/nginx
)"

sudo service consul start || sudo service consul restart

logger "Done"

exit 0
