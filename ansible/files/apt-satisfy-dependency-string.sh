#!/bin/bash
# A wrapper around 'apt satisfy' that allows it to be called safely through sudo
# without passing arbitrary arguments to apt.
set -eo pipefail

if [[ -n "$*" ]]; then
    echo "Installing dependencies: $*"
    exec apt satisfy -y --no-install-recommends --no-install-suggests "$*"
else
    echo "No dependencies to satisfy."
fi
