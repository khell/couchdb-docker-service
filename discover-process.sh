#!/bin/bash

# Wait until docker has finished setting up /etc/hosts
/wait-for-host.sh ${SERVICE_NAME}${TASK_SLOT}

