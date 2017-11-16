#!/bin/bash

# Sleep for 60 seconds to allow other containers to initialize, and Consul to be updated
# ... This is still possibly a race condition. We could check the Docker API in future to see
# if all replicas are online.
sleep 60

HOST=$(ip route show | awk '/default/ {print $3}')
echo "Docker host address is $HOST"

# Extract from Consul endpoint
CONTAINERS=$(
    curl -L http://$HOST:8500/v1/catalog/service/$SERVICE_NAME-5984 |
    jq -r '.[] | "\(.ServiceAddress) couchdb\(.ServiceID | split(".")[1])"'
)

# Prepend to hosts file (override existing entries)
echo -e "Adding to hosts file:\n$CONTAINERS"
printf '%s\n%s\n' "$CONTAINERS" "$(cat /etc/hosts)" > /etc/hosts
