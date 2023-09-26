#!/usr/bin/env bash

NODE_VERSION=18.17.1

# Make sure `nodenv` is installed.
if ! [[ $(which nodenv) ]]; then
    echo "Installing Nodenv..."
    brew install nodenv
    echo -e "Nodenv installation successful!\n"
fi

# Setup Nodenv.
eval "$(nodenv init -)"

# Install Node.
nodenv install ${NODE_VERSION}
nodenv global ${NODE_VERSION}
echo -e "Node installation successful!\n"

# Install global NPM packages.
if [[ $(which npm) ]]; then
    echo "Installing global NPM packages..."
    npm install -g prettier
    echo -e "NPM packages installed successfully!\n"
fi
