# Overview

The USAN Dialogflow Enterprise Telephony Gateway provides media server functionality as well as enterprise telephony (SIP) connectivity between Google Dialogflow Enterprise 
and the companies' enterprise telephony components (PBX or SBC). 

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this telephony bridge to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
on-screen instructions:
*TODO: link to solution details page*

## Command line instructions

Follow these instructions to install the USAN Dialogflow Enterprise Telephony Gateway from the command line.

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
export APP_INSTANCE_NAME=dialogflow-entperise-telephony-gateway-1
export NAMESPACE=default
export IMAGE_GATEWAY=launcher.gcr.io/usan-gcp/dialogflow-entperise-telephony-gateway-de:1
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

The Gateway appliance does not store any long-term data. Backups are not necessary.

# Upgrades

There is no upgrade path. It is recommended you stand up a new appliance and transition your
traffic to that new appliance.
