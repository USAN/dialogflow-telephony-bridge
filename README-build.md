# Overview

This document will describe how to build the kubernetes cluster from scratch.

# Quick Start

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this telephony bridge to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
on-screen instructions:
*TODO: link to solution details page*

# Manual Build

## Prerequisites

- Follow the instructions in the [marketplace tools README](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/aca27e694dc2ab6304a373a0906a802cb26896aa/docs/mpdev-references.md) 
    for setting up gcloud, kubectl, docker, and the other associated dependencies
    required.
- Set up gcloud docker container repository authentication
    ```
    gcloud auth configure-docker
    ```

## Build process

1. Set the necessary environment variables:
    ```
    export ZONE=us-east1-b              # set when the cluster was created
    export CLUSTER=my-dfe-bridge-1      # set when the cluster was created
    ```
1. Update the submodules
    ```
    git submodule update --init --recursive
    ```
1. Install the Custom Resource Definition
    ```
    kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
    ```
1. Build the containers.
    ```
    make app/build
    ```

