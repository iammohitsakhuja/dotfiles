#!/usr/bin/env bash

# Source platform utilities for consistent package installation
source "$(dirname "${BASH_SOURCE[0]}")/../utils/platform.sh"

# Make sure `rbenv` is installed.
install_package_if_missing "rbenv"

# Setup Rbenv.
eval "$(rbenv init -)"

# Get the latest stable Ruby version from rbenv
RUBY_VERSION=$(rbenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

# Fallback to a known stable version if detection fails
if [[ -z ${RUBY_VERSION} ]]; then
    RUBY_VERSION="3.4.5"
    echo "Warning: Could not detect latest Ruby version, using fallback: ${RUBY_VERSION}"
fi

echo "Using Ruby version: ${RUBY_VERSION}"

# Install Ruby.
rbenv install "${RUBY_VERSION}" --skip-existing
rbenv global "${RUBY_VERSION}"
echo -e "Ruby installation successful!\n"

# Install Ruby gems.
if command -v gem &>/dev/null; then
    echo "Installing Gems..."
    # Uncomment the following line, and add gem names to install global gems.
    # gem install
    # Uncomment the following to add man pages support to installed gems.
    # gem manpages --update-all

    echo -e "Gems installed successfully!\n"
else
    echo -e "Gem command not found! Skipping gems' installation...\n"
fi
