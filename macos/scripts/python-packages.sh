#!/usr/bin/env bash

PYTHON_VERSION=3.11.5

# Make sure `pyenv` is installed.
if ! command -v pyenv &>/dev/null; then
    echo "Installing Pyenv..."
    brew install pyenv
    echo -e "Pyenv installation successful!\n"
fi

# Setup Pyenv.
eval "$(pyenv init -)"

# Install Python.
pyenv install "${PYTHON_VERSION}"
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
