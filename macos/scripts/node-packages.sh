#!/usr/bin/env bash

# Source platform utilities for consistent package installation
source "$(dirname "${BASH_SOURCE[0]}")/../utils/platform.sh"

# Make sure `nodenv` is installed.
install_package_if_missing "nodenv"

# Setup Nodenv.
eval "$(nodenv init -)"

# Get the latest stable Node.js version from nodenv
NODE_VERSION=$(nodenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

# Fallback to a known stable version if detection fails
if [[ -z ${NODE_VERSION} ]]; then
    NODE_VERSION="24.6.0"
    echo "Warning: Could not detect latest Node.js version, using fallback: ${NODE_VERSION}"
fi

echo "Using Node.js version: ${NODE_VERSION}"

# Install Node.
nodenv install "${NODE_VERSION}" --skip-existing
nodenv global "${NODE_VERSION}"
echo -e "Node installation successful!\n"

# Install global NPM packages.
if command -v npm &>/dev/null; then
    echo "Installing global NPM packages..."
    npm install -g prettier
    echo -e "NPM packages installed successfully!\n"
fi
