#!/usr/bin/env bash

# Install Pip packages.
if [[ $(which pip3) ]]; then
    echo "Installing Pip packages..."
    pip3 install black
    pip3 install gitlint
    pip3 install neovim
    pip3 install virtualenv
    echo -e "Pip packages installed successfully!\n"
else
    echo -e "Pip3 not found! Skipping Pip packages' installation...\n"
fi
