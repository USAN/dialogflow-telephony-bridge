#! /bin/bash

# Provide default values for environment variables
# syntax here is ${vername:-defaultvalue}

# general asterisk configuration items
export VERBOSITY=${VERBOSITY:-3}
export DEBUGITY=${DEBUGITY:-0}
export LANGUAGE=${LANGUAGE:-en-US}

# general environment variable
# HTTP_PROXY=${HTTP_PROXY:-} # no default

# configurations for res_speech_gdfe.conf
# SERVICE_KEY=${SERVICE_KEY:-} # default is empty
# ENDPOINT=${ENDPOINT:-} # default is empty
export VAD_VOICE_THRESHOLD=${VAD_VOICE_THRESHOLD:-512} # amplitude 0-(2^15-1)
export VAD_VOICE_MINIMUM_DURATION=${VAD_VOICE_MINIMUM_DURATION:-20}

# pjsip configuration items
# export EXTERNAL_IP=${EXTERNAL_IP:-} # has no default

# metering agent configuration items
export AGENT_PORT=${AGENT_PORT:-4242}

# Check for external cluster IP
if [ "${EXTERNAL_IP}" = "" ] ; then
        echo "ERROR: Load balancer name is not defined, please define external EXTERNAL_IP enviromental variable."
        echo "ERROR: Shutting down uDFE APP"
        sleep 5
        exit 1
fi

LOAD_BALANCER_NAME="${EXTERNAL_IP}"
EXTERNAL_IP=$(curl curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes/api/v1/namespaces/default/services/dialogflow-telephony-bridge-1-dfe-switch-svc 2>/dev/null | jq '.status.loadBalancer.ingress[0].ip')
while [ ! -n "${EXTERNAL_IP}" ] ; do
    printf "INFO: Waiting for external IP to be allocated to load balancer ${LOAD_BALANCER_NAME}\n"
    sleep 5
    EXTERNAL_IP=$(curl curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes/api/v1/namespaces/default/services/dialogflow-telephony-bridge-1-dfe-switch-svc 2>/dev/null | jq '.status.loadBalancer.ingress[0].ip')
done

mkdir -p /etc/asterisk

# Update asterisk conf files
for f in etc_asterisk/* ; do
    if [ $(basename $f) != "extensions.conf" ] ; then
        cat $f | envsubst | tee /etc/asterisk/$(basename $f)
    else
        cp $f /etc/asterisk/$(basename $f)
    fi
done

# actual startup logic -- mostly taken from safe_asterisk
MAXFILES=$((`cat /proc/sys/fs/file-max` / 2))
if test $MAXFILES -gt 1048576; then
    MAXFILES=1048576
fi

ulimit -n $MAXFILES

PRIORITY=0
RUNDIR=/tmp

if test -n "${HTTP_PROXY}" ; then
    export http_proxy=${HTTP_PROXY}
fi

cd ${RUNDIR}
nice -n ${PRIORITY} "/usr/sbin/asterisk" -c
