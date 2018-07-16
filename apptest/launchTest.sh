#! /bin/bash

PROJECT_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
IP=$(getent hosts ${HOST} | head -n 1 | awk '{ print $1 }')

node index.js --svc "${PROJECT_ID}" --host "${IP}"

RESULT=$?

if [ "$RESULT" = "0" ]; then
    echo SUCCESS
else
    echo FAILURE
    exit 1
fi
