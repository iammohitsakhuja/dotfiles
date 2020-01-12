#!/usr/bin/env bash

# Install Pip.
echo "Installing Pip..."
yay -S python-pip
echo -e "Done\n"

# Install pip packages.
sudo pip install black gitlint neovim virtualenv
