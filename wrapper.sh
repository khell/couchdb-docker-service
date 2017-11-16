#!/bin/bash

# Adaptation of https://docs.docker.com/engine/admin/multi-service_container/

# Start the discover process
#echo "Starting the discovery..."
#/discover-process.sh

# Setup hosts file to make all containers routable under Swarm Mode
echo "Starting the host discovery via Consul..."
/setup-hosts.sh

# Start the couchdb process
echo "Starting CouchDB..."
/couchdb-process.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start couchdb-process: $status"
  exit $status
fi

# Start the set-up process in the foreground after the DBs are ready. We expect this process to
# complete and then the script will continue on and monitor the other 2 processes.
echo "Starting setup..."
/set-up-process.sh

# Naive check runs checks once a minute to see if either of the processes exited. The container will
# exit with an error

echo "Entering loop..."
while /bin/true; do
  COUCHDB_STATUS=$(ps aux | grep couchdb-process | grep -v grep | wc -l)

  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrongz

  if [ $COUCHDB_STATUS -ne 1 ]; then
    echo "couchdb-processes has exited."
    exit -1
  fi

  sleep 30
done
