#! /bin/bash

IP=$(getent hosts ${HOST} | head -n 1 | awk '{ print $1 }')

node index.js --svc "1234567890" --host "${IP}"

RESULT=$?

if [ "$RESULT" = "0" ]; then
    echo SUCCESS
else
    echo FAILURE
    exit 1
fi
