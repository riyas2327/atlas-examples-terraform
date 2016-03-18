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
