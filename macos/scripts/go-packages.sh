#!/usr/bin/env bash

# Source platform utilities for consistent package installation
source "$(dirname "${BASH_SOURCE[0]}")/../utils/platform.sh"

# Make sure `goenv` is installed.
install_package_if_missing "goenv"

# Setup Goenv.
eval "$(goenv init -)"

# Use the latest Go version
GO_VERSION=latest

# Install Go.
goenv install "${GO_VERSION}" --skip-existing
goenv global "${GO_VERSION}"
echo -e "Go installation successful!\n"

# Install Go packages.
if command -v go &>/dev/null; then
    echo "Installing Go packages..."
    # Uncomment the following line, and add package names to install global go packages.
    # go install
    echo -e "Go packages installed successfully!\n"
fi
