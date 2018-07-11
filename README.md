# Overview

The USAN DialogFlow Telephony Bridge allows you to connect your VOIP PBX to the 
Dialogflow API.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this telephony bridge to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
on-screen instructions:
*TODO: link to solution details page*

## Command line instructions

Follow these instructions to install the USAN Dialogflow Telephony Bridge from the command line.

### Prerequisites

- Setup cluster
  - Permissions
- Setup kubectl
- Install Application Resource
- Acquire License

*TODO: add details above*

### Commands

Set environment variables (modify if necessary):
```
export APP_INSTANCE_NAME=dialogflow-telephony-bridge-1
export NAMESPACE=default
export IMAGE_WORDPRESS=launcher.gcr.io/google/dialogflow-telephony-bridge:1
export IMAGE_INIT=launcher.gcr.io/google/dialogflow-telephony-bridge/init:1 ???
export IMAGE_UBBAGENT=launcher.gcr.io/google/ubbagent
```

Expand manifest template:
```
cat manifest/* | envsubst > expanded.yaml
```

Run kubectl:
```
kubectl apply -f expanded.yaml
```

*TODO: fix instructions*

# Backups

*TODO: instructions for backups*

# Upgrades

*TODO: instructions for upgrades*
