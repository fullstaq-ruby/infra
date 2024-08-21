#!/usr/bin/env bash
set -eo pipefail

REPO=fullstaq-ruby/infra
DIST_NAME=$(lsb_release --id --short | tr '[:upper:]' '[:lower:]')
DIST_VERSION=$(lsb_release --release --short)
ARCHITECTURE=$(dpkg --print-architecture)
INSTALL_DIR=/opt/apiserver/versions
KEEP_LAST_VERSIONS=5

# Fetch the latest release information from the GitHub API
echo "Fetching https://api.github.com/repos/$REPO/releases/latest..."
LATEST_RELEASE=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
LATEST_RELEASE_TAG=$(echo "$LATEST_RELEASE" | jq -r .tag_name)
echo "Latest version: $LATEST_RELEASE_TAG"

# Find the right asset for our system
ASSET_NAME="${LATEST_RELEASE_TAG}-${DIST_NAME}-${DIST_VERSION}-${ARCHITECTURE}.tar.zst"
echo "Looking for asset: $ASSET_NAME"
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r --arg ASSET_NAME "$ASSET_NAME" '.assets[] | select(.name == $ASSET_NAME) | .browser_download_url')
if [[ -z "$ASSET_URL" ]]; then
    echo "ERROR: asset not found in release."
    exit 1
fi
echo "Found asset URL: $ASSET_URL"

# Install asset if not already installed
TARGET_BASENAME="${LATEST_RELEASE_TAG}-${DIST_NAME}-${DIST_VERSION}-${ARCHITECTURE}"
TARGET_DIR="${INSTALL_DIR}/${TARGET_BASENAME}"
if [[ -d "$TARGET_DIR" ]]; then
    echo "Asset already installed under $TARGET_DIR."
else
    echo "Installing asset to $TARGET_DIR..."

    curl -fsSLo "/tmp/$ASSET_NAME" "$ASSET_URL"
    rm -rf "${TARGET_DIR}.tmp"
    mkdir "${TARGET_DIR}.tmp"
    tar --use-compress-program=unzstd -xf "/tmp/$ASSET_NAME" -C "${TARGET_DIR}.tmp"
    DPKG_DEPENDENCIES=$(cat "${TARGET_DIR}.tmp/dpkg-dependencies.txt")
    if [[ -z "$DPKG_DEPENDENCIES" ]]; then
        echo "Installing dependencies: $DPKG_DEPENDENCIES"
        apt satisfy -y --no-install-recommends --no-install-suggests "$DPKG_DEPENDENCIES"
    fi
    rm "/tmp/$ASSET_NAME"
    mv "${TARGET_DIR}.tmp" "$TARGET_DIR"

    echo "Cleaning old versions, keep only last ${KEEP_LAST_VERSIONS}..."
    find "$INSTALL_DIR" -maxdepth 1 -type d | tail -n +2 | sort -V | head -n "-${KEEP_LAST_VERSIONS}" | while read -r OLD_VERSION; do
        OLD_VERSION_BASENAME=$(basename "$OLD_VERSION")
        echo "Removing old version: ${OLD_VERSION_BASENAME}"
        rm -rf "$OLD_VERSION"
    done
fi

# Activate latest version
ln -sfn "$TARGET_BASENAME" /opt/apiserver/versions/latest

echo "Completed setup."
