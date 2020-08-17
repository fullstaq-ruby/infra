#!/bin/bash
set -ex
gcloud services enable \
    compute.googleapis.com \
    container.googleapis.com \
    containerregistry.googleapis.com \
    dns.googleapis.com \
    servicenetworking.googleapis.com \
    storage-component.googleapis.com
