#!/usr/bin/env bash

# Make sure `pyenv` is installed.
if ! command -v pyenv &>/dev/null; then
    echo "Installing Pyenv..."
    brew install pyenv
    echo -e "Pyenv installation successful!\n"
fi

# Setup Pyenv.
eval "$(pyenv init -)"

# Get the latest stable Python version from pyenv
PYTHON_VERSION=$(pyenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 | sed 's/^[[:space:]]*//')

# Fallback to a known stable version if detection fails
if [[ -z ${PYTHON_VERSION} ]]; then
    PYTHON_VERSION="3.13.7"
    echo "Warning: Could not detect latest Python version, using fallback: ${PYTHON_VERSION}"
fi

echo "Using Python version: ${PYTHON_VERSION}"

# Install Python.
pyenv install "${PYTHON_VERSION}" --skip-existing
pyenv global "${PYTHON_VERSION}"
echo -e "Python installation successful!\n"

# Install Pip packages.
if command -v pip3 &>/dev/null; then
    echo "Installing Pip packages..."
    pip3 install black gitlint neovim virtualenv
    echo -e "Pip packages installed successfully!\n"
else
    echo -e "Pip3 not found! Skipping Pip packages' installation...\n"
fi
